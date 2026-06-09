const TestCaseResult := preload("./test_case_result.gd")


var source_file: GDScript:
	get: return _source_file

var all_results: Array[TestCaseResult]:
	get: return _all_results

var failed_results: Array[TestCaseResult]:
	get: return _failed_results

var passed_results: Array[TestCaseResult]:
	get: return _passed_results

var passed: bool:
	get: return _failed_results.size() == 0

var _source_file: GDScript
var _all_results: Array[TestCaseResult]
var _failed_results: Array[TestCaseResult]
var _passed_results: Array[TestCaseResult]


func _init(source_file_value: GDScript, results: Array[TestCaseResult]) -> void:
	_source_file = source_file_value
	_all_results = results
	_populate_passed_and_failed_results()


func to_dictionary() -> Dictionary:
	return {
		"file_path": source_file.resource_path,
		"cases": all_results.map(func(result: TestCaseResult): return result.to_dictionary()),
	}


func _populate_passed_and_failed_results() -> void:
	var new_results: Array[TestCaseResult] = []
	var new_passed_results: Array[TestCaseResult] = []

	for test_case_result in _all_results:
		if test_case_result.passed:
			new_passed_results.append(test_case_result)
		else:
			new_results.append(test_case_result)

	_failed_results = new_results
	_passed_results = new_passed_results
