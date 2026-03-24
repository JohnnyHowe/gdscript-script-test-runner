# Scope
Can test any plain objects.

# Running Tests
```
godot --headless -s addons/gdscript-script-test-runner/src/run_tests.gd
```

## Running Specific Tests
The first two arguments after the above command are file and method filters (regex).

```
godot --headless -s addons/gdscript-script-test-runner/src/run_tests.gd -- file_filter=<file_filter>, method_filter=<method_filter>
```

For example

```
godot --headless -s addons/gdscript-script-test-runner/src/run_tests.gd -- file_filter=.*my_enemy_scripts.*, method_filter=test_count_each_item_empty
```

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

# CLI Parameters

| Name | Type | Description |
| - | - | - |
| `file_filter` | `String` | regex pattern for refining test file search.<br><br>for example, `file_filter=.*my_script.tests.gd` will match any file named `my_script.tests.gd` in the project.
| `method_filter` | `String` | regex pattern for filtering test methods. Same usage as `file_filter`.
