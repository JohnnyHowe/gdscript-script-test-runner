## Converts supported test return values into ScriptTestResult instances.


static func standardize(original_test_result: Variant) -> ScriptTestResult:
	if original_test_result is ScriptTestResult:
		return original_test_result
	if original_test_result is bool:
		return ScriptTestResult.new(original_test_result)
	if original_test_result is Array:
		return _from_array(original_test_result)
	return ScriptTestResult.new(false, "Result unknown: Received %s: \"%s\"" % [type_string(typeof(original_test_result)), str(original_test_result)])


static func _from_array(original_test_results: Array) -> ScriptTestResult:
	var failure_reasons: Array[String] = []
	for original_result in original_test_results:
		var result := standardize(original_result)
		if result.passed:
			continue
		failure_reasons.append(result.message)
	if failure_reasons.is_empty():
		return ScriptTestResult.new(true)

	var prefix := "- "
	return ScriptTestResult.new(false, prefix + ("\n" + prefix).join(failure_reasons))
