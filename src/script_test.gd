class_name ScriptTest

var name: String
var test_function: Callable

var file_path: String
var file_instance: Object
var method_name: String


func run_test() -> ScriptTestResult:
	var raw_result = test_function.call()
	var compiled_result := _get_valid_test_result(raw_result)
	compiled_result.test = self
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


func _to_string() -> String:
	return "%s<%s from %s.%s>" % [get_script().get_global_name(), file_path, method_name]
