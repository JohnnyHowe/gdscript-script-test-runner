# Scope
Can test any plain objects.

# Running Tests
With python wrapper (preferred - Godot is a bit weird in some consoles)
```
python addons/gdscript-script-test-runner/src/run_tests.py
```

or with Godot directly
```
godot --headless --quit -s addons/gdscript-script-test-runner/src/run_tests.gd
```

To write structured result files:
```
godot --headless --quit -s addons/gdscript-script-test-runner/src/run_tests.gd -- results_file_json=res://test_results.json results_file_md=res://test_results.md
```

# VS Code Extension
This addon includes a local VS Code extension in `vscode-extension/` that discovers and runs tests from VS Code's Test Explorer.

From the root of the project that contains this addon, run:
```
.\godot\addons\gdscript-script-test-runner\install_vscode_extension.bat
```

Then reload VS Code with `Developer: Reload Window`.

# Running Discovery
The discovery CLI writes JSON metadata for test files and test cases. This is used by the VS Code extension and can also be used by other tooling.

```
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- results_file=res://discovered_tests.json hide_results=true
```

Useful filters:
```
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- test_file_pattern=combat test_name_pattern=^test_ results_file=res://discovered_tests.json
```

# Test Runner CLI Parameters (Godot)

| Name | Type | Default | Description |
| - | - | - | - |
| `test_suite_file` | `String` | NA | JSON test suite file to run instead of discovering tests.
| `results_file_json` | `String` | NA | File to write JSON test results to. Does not write if no path is given.
| `results_file_md` | `String` | NA | File to write Markdown test results to. Does not write if no path is given.

## CLI Parameters (Python)

**NOTE: The python wrapper requires `godot` to be on your PATH.**

The Python wrapper is a convenience entry point for running the suite from a chosen project root. Use the Godot CLIs directly for structured JSON/Markdown output or discovery JSON.

| Name | Type | Default | Description |
| - | - | - | - |
| `--project-root` | `String` | CWD | Path to the Godot project root.

# Discovery CLI Parameters (Godot)

| Name | Type | Default | Description |
| - | - | - | - |
| `test_file_pattern` | `String` | `.*` | Regex pattern for refining test file search.<br><br>For example, `test_file_pattern=.*my_script.tests.gd` will match any file named `my_script.tests.gd` in the project.
| `test_name_pattern` | `String` | `.*` | Regex pattern for filtering test methods. Same usage as `test_file_pattern`.
| `results_file` | `String` | NA | File to write discovery JSON to. Does not write if no path is given.
| `hide_results` | `bool` | `false` | Do not print discovery JSON to stdout.

# Making Tests
All tests must be in files ending with `.tests.gd`

## Unit Tests
```gdscript
func test_<name>() -> TestCaseResult | Array[TestCaseResult]
```

For example

```gdscript
func test_condition() -> TestCaseResult:
	...
	return TestCaseResult.new(condition)
```

## Unit Test Generator
To programmatically create unit tests

```gdscript
func <name>_test_generator() -> Dictionary[String, Callable]
```

For example (this is not a good test, but a syntactically valid generator)

```gdscript
func my_method_test_generator() -> Dictionary[String, Callable]:
	var tests = {}
	for item_name in ["item1", "item2", "item3"]:
		tests["test_my_test_method_with" + item_name] = func(): return my_test_method(i)
	return tests
```
