var source_file: GDScript:
	get: return _source_file

var all_results: Array[ScriptTestResult]: 
	get: return _all_results

var failed_results: Array[ScriptTestResult]:
	get: return _failed_results

var passed_results: Array[ScriptTestResult]:
	get: return _passed_results

var passed: bool:
	get: return _failed_results.size() == 0

var _source_file: GDScript
var _all_results: Array[ScriptTestResult]
var _failed_results: Array[ScriptTestResult]
var _passed_results: Array[ScriptTestResult]


func _init(source_file_value: GDScript, results: Array[ScriptTestResult]) -> void:
	_source_file = source_file_value
	_all_results = results
	_populate_passed_and_failed_results()


func _populate_passed_and_failed_results() -> void:
	var new_results: Array[ScriptTestResult] = []
	var new_passed_results: Array[ScriptTestResult] = []

	for script_test_result in _all_results:
		if script_test_result.passed:
			new_passed_results.append(script_test_result)
		else:
			new_results.append(script_test_result)

	_failed_results = new_results
	_passed_results = new_passed_results
