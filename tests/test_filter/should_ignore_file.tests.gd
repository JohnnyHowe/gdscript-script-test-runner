const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")


func test_should_ignore_file_respects_file_filter() -> Array[ScriptTestResult]:
	var filter := _TestFilter.new(".*\\.tests\\.gd$", ".*", [] as Array[String])
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(false, filter.should_ignore_file("res://tests/sample.tests.gd")))
	results.append(ScriptTestResult.from_equals(true, filter.should_ignore_file("res://tests/sample.gd")))
	return results


func test_should_ignore_file_respects_ignored_patterns() -> Array[ScriptTestResult]:
	var ignored: Array[String] = [_TestFilter.get_path_ignore_pattern("res://.godot")]
	var filter := _TestFilter.new(".*", ".*", ignored)
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(true, filter.should_ignore_file("res://.godot/cache/foo.tests.gd")))
	results.append(ScriptTestResult.from_equals(false, filter.should_ignore_file("res://tests/foo.tests.gd")))
	return results
