# Scope
Can test any plain objects.

# Running Tests
With python wrapper (preferred - Godot is a bit weird in some consoles)
```
python addons/gdscript-script-test-runner/src/run_tests.py
```

or with Godot directly
```
godot --headless -s addons/gdscript-script-test-runner/src/run_tests.gd
```

# CLI Parameters (Godot)

| Name | Type | Default | Description |
| - | - | - | - |
| `test_file_pattern` | `String` | `.*` | Regex pattern for refining test file search.<br><br>For example, `test_file_pattern=.*my_script.tests.gd` will match any file named `my_script.tests.gd` in the project.
| `test_name_pattern` | `String` | `.*` | Regex pattern for filtering test methods. Same usage as `test_file_pattern`.
| `hide_passed_tests` | `bool` | `false` | Hide passed tests in the output.
| `print_results` | `bool` | `true` | Print the test log to stdout.
| `results_file` | `String` | NA | File to write the output log to. Does not write if no path given.
| `fail_fast` | `bool` | `false` | Stop execution as soon as the first failed test is encountered.

## CLI Parameters (Python)

**NOTE: The python wrapper requires `godot` to be on your PATH.**

| Name | Type | Default | Description |
| - | - | - | - |
| `--project-root` | `String` | CWD | Path to the Godot project root.
| `--test-file-pattern` | `String` | `.*` | Regex for test file paths.
| `--test-name-pattern` | `String` | `.*` | Regex for test method names.
| `--hide-passed-tests` | `bool` | `false` | Hide passed tests in the output.
| `--print-results`, `--no-print-results` | `bool` | `true` | Print the test log to stdout.
| `--results-file` | `String` | NA | Write the log to a file.
| `--fail-fast` | `bool` | `false` | Stop execution as soon as the first failed test is encountered.

# Making Tests
All tests must be in files ending with `.tests.gd`

## Unit Tests
```gdscript
func test_<name>() -> ScriptTestResult | Array[ScriptTestResult]
```

For example

```gdscript
func test_condition() -> ScriptTestResult:
	...
	return ScriptTestResult.new(condition)
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
