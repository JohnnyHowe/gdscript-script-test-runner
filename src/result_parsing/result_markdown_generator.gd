const TestSuiteResult := preload("../data/results/test_suite_result.gd")
const TestFileResult := TestSuiteResult.TestFileResult
const TestCaseResult := TestFileResult.TestCaseResult

var _result: TestSuiteResult

var _all_case_results: Array[TestCaseResult]
var _passed_case_results: Array[TestCaseResult]
var _failed_case_results: Array[TestCaseResult]


func _init(result: TestSuiteResult) -> void:
	_result = result
	_generate_collated_cases()


func as_string() -> String:
	return _generate_summary_string()


func _generate_summary_string() -> String:
	return "\n".join([
		"# Summary",
		"| Key | Cases | Files |",
		"| - | - | - |",
		"| Total | %s | %s |" % [_all_case_results.size(), _result._all_results.size()],
		"| Passed | %s | %s |" % [_passed_case_results.size(), _result.passed_results.size()],
		"| Failed | %s | %s |" % [_failed_case_results.size(), _result.failed_results.size()],
	])


func _generate_collated_cases() -> void:
	_generate_all_collated_cases()
	_passed_case_results = []
	_failed_case_results = []
	for case_result: TestCaseResult in _all_case_results:
		if case_result.passed:
			_passed_case_results.append(case_result)
		else:
			_failed_case_results.append(case_result)


func _generate_all_collated_cases() -> void:
	_all_case_results = []
	for file_result: TestFileResult in _result.all_results:
		for case_result in file_result.all_results:
			_all_case_results.append(case_result)
