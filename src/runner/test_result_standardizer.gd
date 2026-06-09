## Converts supported test return values into TestCaseResult instances.


static func standardize(original_test_result: Variant) -> TestCaseResult:
	if original_test_result is TestCaseResult:
		return original_test_result
	if original_test_result is bool:
		return TestCaseResult.new(original_test_result)
	if original_test_result is Array:
		return _from_array(original_test_result)
	return TestCaseResult.new(false, "Result unknown: Received %s: \"%s\"" % [type_string(typeof(original_test_result)), str(original_test_result)])


static func _from_array(original_test_results: Array) -> TestCaseResult:
	var failure_reasons: Array[String] = []
	for original_result in original_test_results:
		var result := standardize(original_result)
		if result.passed:
			continue
		failure_reasons.append(result.message)
	if failure_reasons.is_empty():
		return TestCaseResult.new(true)

	var prefix := "- "
	return TestCaseResult.new(false, prefix + ("\n" + prefix).join(failure_reasons))
