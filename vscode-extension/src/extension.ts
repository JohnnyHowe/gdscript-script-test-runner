import * as vscode from "vscode";
import * as path from "path";

const controllerId = "gdscriptScriptTestRunner.tests";
const controllerLabel = "GDScript Script Test Runner";
const discoveryResultsPath = "discovered_tests.json";

interface DiscoveryResults {
	test_scripts?: DiscoveredTestScript[];
}

interface DiscoveredTestScript {
	file_path: string;
	tests?: DiscoveredTest[];
}

interface DiscoveredTest {
	file_path: string;
	name: string;
	source_method: string;
	line: number;
	kind: string;
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

	const discoveryResults = await loadDiscoveryResults(projectRoot);
	if (discoveryResults === undefined) {
		vscode.window.showInformationMessage("No discovered_tests.json file found yet.");
		return;
	}

	loadTestsFromDiscoveryResults(controller, projectRoot, discoveryResults);
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
	for (const testScript of results.test_scripts ?? []) {
		const scriptUri = resPathToUri(projectRoot, testScript.file_path);
		const scriptItem = controller.createTestItem(
			testScript.file_path,
			path.basename(testScript.file_path),
			scriptUri
		);

		controller.items.add(scriptItem);

		for (const test of testScript.tests ?? []) {
			const testUri = resPathToUri(projectRoot, test.file_path);
			const testItem = controller.createTestItem(
				`${test.file_path}::${test.name}`,
				test.name,
				testUri
			);

			testItem.range = createLineRange(test.line);
			testItem.description = test.kind;
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
