# GDScript Test Runner

Can test any plain objects.

## Usage: CLI

### Python

Since Godot console output seems to behave strangely (sometimes other things can't see any output), there's a small python wrapper.

```bash
python addons/gdscript-script-test-runner/src/run_tests.py
```

### Godot

```bash
godot --headless --quit -s addons/gdscript-script-test-runner/src/run_tests.gd
```

### Parameters

| Name (Godot) | Name (Python) | Type | Default | Description |
| - | - | - | - | - |

TODO

## VS Code Extension

This addon includes a local VS Code extension in `vscode-extension/` that discovers and runs tests from VS Code's Test Explorer.

### Installing

In VSCode, run `Extensions: Install from VSIX...` and select `vscode-extension/gdscript-script-test-runner-vscode.vsix`.

### Rebuilding

From the `vscode-extension` directory, run

```bash
npm install
npm run compile
npm run package
```

## Making Tests

All tests must be in files ending with `.tests.gd`

## Unit Tests

Any function starting with `test_` is considered a test.

For example

```gdscript
func test_always_fail() -> TestCaseResult:
    return TestCaseResult.fail()
```

### Asserting and Return Values

TODO

## REDO THE FOLLOWING!!

### Running Discovery

The discovery CLI writes JSON metadata for test files and test cases. This is used by the VS Code extension and can also be used by other tooling.

```
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- results_file=res://discovered_tests.json hide_results=true
```

Useful filters:

```
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- test_file_pattern=combat test_name_pattern=^test_ results_file=res://discovered_tests.json
```

### Test Runner CLI Parameters (Godot)

| Name | Type | Default | Description |
| - | - | - | - |
| `test_suite_file` | `String` | NA | JSON test suite file to run instead of discovering tests.
| `results_file_json` | `String` | NA | File to write JSON test results to. Does not write if no path is given.
| `results_file_md` | `String` | NA | File to write Markdown test results to. Does not write if no path is given.

#### CLI Parameters (Python)

**NOTE: The python wrapper requires `godot` to be on your PATH.**

The Python wrapper is a convenience entry point for running the suite from a chosen project root. Use the Godot CLIs directly for structured JSON/Markdown output or discovery JSON.

| Name | Type | Default | Description |
| - | - | - | - |
| `--project-root` | `String` | CWD | Path to the Godot project root.

### Discovery CLI Parameters (Godot)

| Name | Type | Default | Description |
| - | - | - | - |
| `test_file_pattern` | `String` | `.*` | Regex pattern for refining test file search.<br><br>For example, `test_file_pattern=.*my_script.tests.gd` will match any file named `my_script.tests.gd` in the project. |
| `test_name_pattern` | `String` | `.*` | Regex pattern for filtering test methods. Same usage as `test_file_pattern`. |
| `results_file` | `String` | NA | File to write discovery JSON to. Does not write if no path is given. |
| `hide_results` | `bool` | `false` | Do not print discovery JSON to stdout. |