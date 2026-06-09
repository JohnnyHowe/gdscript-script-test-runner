import * as vscode from "vscode";
import * as path from "path";
import { execFile } from "child_process";
import { promisify } from "util";

const controllerId = "gdscriptScriptTestRunner.tests";
const controllerLabel = "GDScript Script Test Runner";
const discoveryResultsPath = "discovered_tests.json";
const discoveryScriptPath = "addons/gdscript-script-test-runner/src/discovery/discover.gd";
const execFileAsync = promisify(execFile);

interface DiscoveryResults {
	files?: DiscoveredTestFile[];
}

interface DiscoveredTestFile {
	file_path: string;
	cases?: DiscoveredTestCase[];
}

interface DiscoveredTestCase {
	file_path: string;
	method_name: string;
	line_number: number;
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

	context.subscriptions.push(controller, runProfile, refreshCommand);
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
		for (const [, item] of controller.items) {
			if (token.isCancellationRequested) {
				break;
			}

			run.enqueued(item);
			run.started(item);

			// Stub: invoke Godot headless, parse results, and report pass/fail here.
			run.skipped(item);
		}
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

function loadTestsFromDiscoveryResults(
	controller: vscode.TestController,
	projectRoot: vscode.Uri,
	results: DiscoveryResults
): void {
	for (const testFile of results.files ?? []) {
		const scriptUri = resPathToUri(projectRoot, testFile.file_path);
		const scriptItem = controller.createTestItem(
			testFile.file_path,
			path.basename(testFile.file_path),
			scriptUri
		);

		controller.items.add(scriptItem);

		for (const testCase of testFile.cases ?? []) {
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

function resPathToUri(projectRoot: vscode.Uri, resourcePath: string): vscode.Uri {
	const relativePath = resourcePath.replace(/^res:\/\//, "");
	return vscode.Uri.joinPath(projectRoot, ...relativePath.split("/"));
}

function createLineRange(oneBasedLine: number): vscode.Range {
	const line = Math.max(oneBasedLine - 1, 0);
	return new vscode.Range(line, 0, line, Number.MAX_SAFE_INTEGER);
}
