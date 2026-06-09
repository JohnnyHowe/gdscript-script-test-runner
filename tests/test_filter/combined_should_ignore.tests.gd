const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")


func test_should_ignore_method_respects_method_filter() -> Array[TestCaseResult]:
	var filter := _TestFilter.new(".*", "^test_", [] as Array[String])
	var results: Array[TestCaseResult] = []
	results.append(TestCaseResult.from_equals(false, filter.should_ignore_method("test_example")))
	results.append(TestCaseResult.from_equals(true, filter.should_ignore_method("helper_method")))
	return results


func test_to_string_includes_patterns() -> TestCaseResult:
	var filter := _TestFilter.new("files", "methods", ["ignore"] as Array[String])
	var expected := "TestFilter(files=%s, methods=%s, ignore=%s)" % ["files", "methods", ["ignore"]]
	return TestCaseResult.from_equals(expected, str(filter))
