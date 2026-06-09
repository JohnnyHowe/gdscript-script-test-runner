const TestFileResult := preload("./test_file_result.gd")


var all_results: Array[TestFileResult]:
	get: return _all_results

var failed_results: Array[TestFileResult]:
	get: return _failed_results

var passed_results: Array[TestFileResult]:
	get: return _passed_results

var total_results_count: int:
	get: return _total_results_count

var failed_results_count: int:
	get: return _failed_results_count

var passed_results_count: int:
	get: return _passed_results_count

var passed: bool:
	get: return _failed_results_count == 0

var _all_results: Array[TestFileResult]
var _failed_results: Array[TestFileResult]
var _passed_results: Array[TestFileResult]
var _total_results_count: int
var _failed_results_count: int
var _passed_results_count: int


func _init(results_value: Array[TestFileResult]) -> void:
	_all_results = results_value
	_populate_passed_and_failed_results()
	_populate_result_counts()


func _populate_passed_and_failed_results() -> void:
	var new_failed_results: Array[TestFileResult] = []
	var new_passed_results: Array[TestFileResult] = []

	for file_result in _all_results:
		file_result._populate_passed_and_failed_results()

		var failed_only := file_result.failed_results
		var passed_only := file_result.passed_results

		if failed_only.size() > 0:
			new_failed_results.append(TestFileResult.new(file_result.source_file, failed_only))

		if passed_only.size() > 0:
			new_passed_results.append(TestFileResult.new(file_result.source_file, passed_only))

	_failed_results = new_failed_results
	_passed_results = new_passed_results


func _populate_result_counts() -> void:
	_total_results_count = 0
	_failed_results_count = 0
	_passed_results_count = 0
	for file_result in _all_results:
		_total_results_count += file_result.all_results.size()
		_failed_results_count += file_result.failed_results.size()
		_passed_results_count += file_result.passed_results.size()
