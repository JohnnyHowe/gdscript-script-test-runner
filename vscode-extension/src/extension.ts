import * as vscode from "vscode";
import * as path from "path";
import { execFile, ExecFileException } from "child_process";
import { promisify } from "util";

const controllerId = "gdscriptScriptTestRunner.tests";
const controllerLabel = "GDScript Script Test Runner";
const discoveryResultsPath = "discovered_tests.json";
const discoveryScriptPath = "addons/gdscript-script-test-runner/src/discovery/discover.gd";
const runScriptPath = "addons/gdscript-script-test-runner/src/run_tests.gd";
const runnerWorkDirPath = ".godot/gdscript_script_test_runner";
const requestedTestsPath = `${runnerWorkDirPath}/requested_tests.json`;
const testResultsPath = `${runnerWorkDirPath}/test_results.json`;
const discoveryRefreshDebounceMs = 250;
const execFileAsync = promisify(execFile);

interface DiscoveryResults {
	files?: Array<DiscoveredTestFile | null>;
}

interface DiscoveredTestFile {
	file_path: string;
	cases?: Array<DiscoveredTestCase | null>;
}

interface DiscoveredTestCase {
	file_path: string;
	method_name: string;
	line_number: number;
}

interface RunResults {
	files?: Array<RunResultFile | null>;
}

interface RunResultFile {
	file_path: string;
	cases?: Array<RunResultCase | null>;
}

interface RunResultCase {
	id: string;
	status: "passed" | "failed";
	message?: string;
	logs?: string;
}

export function activate(context: vscode.ExtensionContext) {
	const controller = vscode.tests.createTestController(controllerId, controllerLabel);

	controller.refreshHandler = async () => {
		await discoverTests(controller);
	};

	const runProfile = controller.createRunProfile(
		"Run",
		vscode.TestRunProfileKind.Run,
		async (request, token) => {
			await runTests(controller, request, token);
		},
		true
	);

	const refreshCommand = vscode.commands.registerCommand(
		"gdscriptScriptTestRunner.refreshTests",
		async () => {
			await discoverTests(controller);
		}
	);

	let refreshTimer: ReturnType<typeof setTimeout> | undefined;
	const scheduleRefresh = () => {
		if (refreshTimer !== undefined) {
			clearTimeout(refreshTimer);
		}

		refreshTimer = setTimeout(() => {
			refreshTimer = undefined;
			void discoverTests(controller);
		}, discoveryRefreshDebounceMs);
	};

	const testFileWatcher = vscode.workspace.createFileSystemWatcher("**/*.tests.gd");
	testFileWatcher.onDidCreate(scheduleRefresh);
	testFileWatcher.onDidChange(scheduleRefresh);
	testFileWatcher.onDidDelete(scheduleRefresh);

	const refreshTimerDisposable = new vscode.Disposable(() => {
		if (refreshTimer !== undefined) {
			clearTimeout(refreshTimer);
		}
	});

	context.subscriptions.push(controller, runProfile, refreshCommand, testFileWatcher, refreshTimerDisposable);

	void discoverTests(controller);
}

export function deactivate() {}

async function discoverTests(controller: vscode.TestController): Promise<void> {
	controller.items.replace([]);

	const projectRoot = await findGodotProjectRoot();
	if (projectRoot === undefined) {
		vscode.window.showWarningMessage("Could not find a Godot project.godot file in the workspace.");
		return;
	}

	const discovered = await runDiscovery(projectRoot);
	if (!discovered) {
		return;
	}

	const discoveryResults = await loadDiscoveryResults(projectRoot);
	if (discoveryResults === undefined) {
		vscode.window.showInformationMessage("Discovery did not create discovered_tests.json.");
		return;
	}

	loadTestsFromDiscoveryResults(controller, projectRoot, discoveryResults);
}

async function runDiscovery(projectRoot: vscode.Uri): Promise<boolean> {
	try {
		await execFileAsync(
			"godot",
			[
				"--headless",
				"--quit",
				"-s",
				discoveryScriptPath,
				"--",
				`results_file=res://${discoveryResultsPath}`,
				"hide_results=true"
			],
			{ cwd: projectRoot.fsPath }
		);
		return true;
	} catch (error) {
		const message = error instanceof Error ? error.message : String(error);
		vscode.window.showWarningMessage(`Could not run GDScript test discovery: ${message}`);
		return false;
	}
}

async function runTests(
	controller: vscode.TestController,
	request: vscode.TestRunRequest,
	token: vscode.CancellationToken
): Promise<void> {
	const run = controller.createTestRun(request);

	try {
		const projectRoot = await findGodotProjectRoot();
		if (projectRoot === undefined) {
			failRequestedTests(run, controller, request, "Could not find a Godot project.godot file in the workspace.");
			return;
		}

		const requestedItems = collectRequestedTestItems(controller, request);
		if (requestedItems.length === 0) {
			return;
		}

		for (const item of requestedItems) {
			run.enqueued(item);
		}
		for (const item of requestedItems) {
			run.started(item);
		}

		const suite = createSuiteFromTestItems(requestedItems);
		await writeJsonFile(projectRoot, requestedTestsPath, suite);
		await writeJsonFile(projectRoot, testResultsPath, { files: [] });

		const execution = await runGodotTests(projectRoot, token);
		const results = await loadRunResults(projectRoot);
		if (results === undefined) {
			const detail = execution.message ? ` ${execution.message}` : "";
			failTestItems(run, requestedItems, `GDScript test run did not produce results.${detail}`);
			return;
		}

		reportRunResults(run, requestedItems, results);
	} finally {
		run.end();
	}
}

async function findGodotProjectRoot(): Promise<vscode.Uri | undefined> {
	for (const workspaceFolder of vscode.workspace.workspaceFolders ?? []) {
		const projectFile = vscode.Uri.joinPath(workspaceFolder.uri, "project.godot");
		try {
			await vscode.workspace.fs.stat(projectFile);
			return workspaceFolder.uri;
		} catch {
			// Keep searching other workspace folders.
		}
	}

	return undefined;
}

async function loadDiscoveryResults(projectRoot: vscode.Uri): Promise<DiscoveryResults | undefined> {
	const resultsFile = vscode.Uri.joinPath(projectRoot, discoveryResultsPath);

	try {
		const bytes = await vscode.workspace.fs.readFile(resultsFile);
		return JSON.parse(Buffer.from(bytes).toString("utf8")) as DiscoveryResults;
	} catch {
		return undefined;
	}
}

async function loadRunResults(projectRoot: vscode.Uri): Promise<RunResults | undefined> {
	const resultsFile = vscode.Uri.joinPath(projectRoot, ...testResultsPath.split("/"));

	try {
		const bytes = await vscode.workspace.fs.readFile(resultsFile);
		return JSON.parse(Buffer.from(bytes).toString("utf8")) as RunResults;
	} catch {
		return undefined;
	}
}

function loadTestsFromDiscoveryResults(
	controller: vscode.TestController,
	projectRoot: vscode.Uri,
	results: DiscoveryResults
): void {
	for (const testFile of results.files ?? []) {
		if (!isDiscoveredTestFile(testFile)) {
			continue;
		}

		const scriptUri = resPathToUri(projectRoot, testFile.file_path);
		const scriptItem = controller.createTestItem(
			testFile.file_path,
			path.basename(testFile.file_path),
			scriptUri
		);

		controller.items.add(scriptItem);

		for (const testCase of testFile.cases ?? []) {
			if (!isDiscoveredTestCase(testCase)) {
				continue;
			}

			const testUri = resPathToUri(projectRoot, testCase.file_path);
			const testItem = controller.createTestItem(
				`${testCase.file_path}::${testCase.method_name}`,
				testCase.method_name,
				testUri
			);

			testItem.range = createLineRange(testCase.line_number);
			scriptItem.children.add(testItem);
		}
	}
}

function isDiscoveredTestFile(value: DiscoveredTestFile | null | undefined): value is DiscoveredTestFile {
	return typeof value?.file_path === "string";
}

function isDiscoveredTestCase(value: DiscoveredTestCase | null | undefined): value is DiscoveredTestCase {
	return (
		typeof value?.file_path === "string" &&
		typeof value.method_name === "string" &&
		typeof value.line_number === "number"
	);
}

function collectRequestedTestItems(
	controller: vscode.TestController,
	request: vscode.TestRunRequest
): vscode.TestItem[] {
	const excludedIds = new Set((request.exclude ?? []).map((item) => item.id));
	const roots = request.include ?? Array.from(controller.items, ([, item]) => item);
	const itemsById = new Map<string, vscode.TestItem>();

	for (const root of roots) {
		appendRunnableTestItems(root, itemsById, excludedIds);
	}

	return Array.from(itemsById.values());
}

function appendRunnableTestItems(
	item: vscode.TestItem,
	itemsById: Map<string, vscode.TestItem>,
	excludedIds: Set<string>
): void {
	if (excludedIds.has(item.id)) {
		return;
	}

	if (item.children.size === 0) {
		itemsById.set(item.id, item);
		return;
	}

	for (const [, child] of item.children) {
		appendRunnableTestItems(child, itemsById, excludedIds);
	}
}

function createSuiteFromTestItems(items: vscode.TestItem[]): DiscoveryResults {
	const files = new Map<string, DiscoveredTestFile>();

	for (const item of items) {
		const testCase = testCaseFromItem(item);
		if (testCase === undefined) {
			continue;
		}

		const file = files.get(testCase.file_path) ?? {
			file_path: testCase.file_path,
			cases: []
		};
		file.cases?.push(testCase);
		files.set(testCase.file_path, file);
	}

	return { files: Array.from(files.values()) };
}

function testCaseFromItem(item: vscode.TestItem): DiscoveredTestCase | undefined {
	const separator = item.id.lastIndexOf("::");
	if (separator < 0) {
		return undefined;
	}

	const filePath = item.id.substring(0, separator);
	const methodName = item.id.substring(separator + 2);
	const lineNumber = item.range === undefined ? -1 : item.range.start.line + 1;

	return {
		file_path: filePath,
		method_name: methodName,
		line_number: lineNumber
	};
}

async function writeJsonFile(projectRoot: vscode.Uri, relativePath: string, value: unknown): Promise<void> {
	const pathParts = relativePath.split("/");
	const fileName = pathParts.pop();
	if (fileName === undefined) {
		return;
	}

	const directory = vscode.Uri.joinPath(projectRoot, ...pathParts);
	await vscode.workspace.fs.createDirectory(directory);
	await vscode.workspace.fs.writeFile(
		vscode.Uri.joinPath(directory, fileName),
		Buffer.from(JSON.stringify(value, undefined, "\t"), "utf8")
	);
}

async function runGodotTests(
	projectRoot: vscode.Uri,
	token: vscode.CancellationToken
): Promise<{ message?: string }> {
	return new Promise((resolve) => {
		const child = execFile(
			"godot",
			[
				"--headless",
				"--quit",
				"-s",
				runScriptPath,
				"--",
				`test_suite_file=res://${requestedTestsPath}`,
				`results_file_json=res://${testResultsPath}`,
				"print_to_console=false"
			],
			{ cwd: projectRoot.fsPath },
			(error: ExecFileException | null) => {
				cancellation.dispose();
				resolve({ message: error?.message });
			}
		);

		const cancellation = token.onCancellationRequested(() => {
			child.kill();
		});
	});
}

function reportRunResults(
	run: vscode.TestRun,
	requestedItems: vscode.TestItem[],
	results: RunResults
): void {
	const itemsById = new Map(requestedItems.map((item) => [item.id, item]));
	const reportedIds = new Set<string>();

	for (const file of results.files ?? []) {
		if (file === null) {
			continue;
		}

		for (const testCase of file.cases ?? []) {
			if (!isRunResultCase(testCase)) {
				continue;
			}

			const item = itemsById.get(testCase.id);
			if (item === undefined) {
				continue;
			}

			reportedIds.add(item.id);
			if (typeof testCase.logs === "string" && testCase.logs.length > 0) {
				run.appendOutput(normalizeTestOutput(testCase.logs), undefined, item);
			}

			if (testCase.status === "passed") {
				run.passed(item);
			} else {
				run.failed(item, new vscode.TestMessage(testCase.message ?? "Test failed."));
			}
		}
	}

	for (const item of requestedItems) {
		if (!reportedIds.has(item.id)) {
			run.failed(item, new vscode.TestMessage("No result was reported for this test."));
		}
	}
}

function isRunResultCase(value: RunResultCase | null | undefined): value is RunResultCase {
	return (
		typeof value?.id === "string" &&
		(value.status === "passed" || value.status === "failed")
	);
}

function failRequestedTests(
	run: vscode.TestRun,
	controller: vscode.TestController,
	request: vscode.TestRunRequest,
	message: string
): void {
	failTestItems(run, collectRequestedTestItems(controller, request), message);
}

function failTestItems(run: vscode.TestRun, items: vscode.TestItem[], message: string): void {
	const testMessage = new vscode.TestMessage(message);
	for (const item of items) {
		run.failed(item, testMessage);
	}
}

function resPathToUri(projectRoot: vscode.Uri, resourcePath: string): vscode.Uri {
	const relativePath = resourcePath.replace(/^res:\/\//, "");
	return vscode.Uri.joinPath(projectRoot, ...relativePath.split("/"));
}

function createLineRange(oneBasedLine: number): vscode.Range {
	const line = Math.max(oneBasedLine - 1, 0);
	return new vscode.Range(line, 0, line, Number.MAX_SAFE_INTEGER);
}

function normalizeTestOutput(output: string): string {
	return output.replace(/\r?\n/g, "\r\n");
}
