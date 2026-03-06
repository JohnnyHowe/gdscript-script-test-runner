# Scope
Can test any plain objects.

# Running Tests
```gdscript
godot --headless -s addons/script-test-runner/run_tests.gd
```

## Running Specific Tests
The first two arguments after the above command are file and method filters (regex).

```gdscript
godot --headless -s addons/script-test-runner/run_tests.gd -- file_filter=<file_filter>, method_filter=<method_filter>
```

For example

```gdscript
godot --headless -s addons/script-test-runner/run_tests.gd -- file_filter=.*my_enemy_scripts.*, method_filter=test_count_each_item_empty
```

Will run any method matching `test_count_each_item_empty` in any file matching `array_util`.

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
