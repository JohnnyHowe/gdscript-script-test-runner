import * as vscode from "vscode";

export function activate(context: vscode.ExtensionContext) {
	const helloCommand = vscode.commands.registerCommand(
		"gdscriptScriptTestRunner.hello",
		() => {
			vscode.window.showInformationMessage("GDScript Script Test Runner extension is active.");
		}
	);

	context.subscriptions.push(helloCommand);
}

export function deactivate() {}
