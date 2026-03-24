const _TestDataObjects := preload("../test_data_objects/main.gd")


static func run(test: _TestDataObjects.Test) -> ScriptTestResult:
	var raw_result = test.test_function.call()
	var compiled_result := _get_valid_test_result(raw_result)
	compiled_result.test = test
	return compiled_result


static func _get_valid_test_result(original_test_result) -> ScriptTestResult:
	if original_test_result is ScriptTestResult:
		return original_test_result
	if original_test_result is bool:
		return ScriptTestResult.new(original_test_result)
	if original_test_result is Array:
		return _get_valid_test_result_from_array(original_test_result)
	return ScriptTestResult.new(false, "Result unknown: Recieved %s: \"%s\"" % [type_string(typeof(original_test_result)), str(original_test_result)])


static func _get_valid_test_result_from_array(original_test_results: Array) -> ScriptTestResult:
	var failure_reasons: Array[String] = []
	for original_result in original_test_results:
		var result = _get_valid_test_result(original_result)
		if result.passed:
			continue
		failure_reasons.append(result.message)
	var prefix = "- "
	return ScriptTestResult.new(failure_reasons.size() == 0, prefix + ("\n" + prefix).join(failure_reasons))
