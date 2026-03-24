const _Configuration := preload("../configuration.gd")
const _TestScriptResults := preload("./test_script_results.gd")


var configuration: _Configuration:
	get: return _configuration

var all_results: Array[_TestScriptResults]:
	get: return _all_results

var failed_results: Array[_TestScriptResults]:
	get: return _failed_results

var passed_results: Array[_TestScriptResults]:
	get: return _passed_results

var total_results_count: int:
	get: return _total_results_count

var failed_results_count: int:
	get: return _failed_results_count

var passed_results_count: int:
	get: return _passed_results_count

var passed: bool:
	get: return _failed_results_count == 0

var _configuration: _Configuration
var _all_results: Array[_TestScriptResults]
var _failed_results: Array[_TestScriptResults]
var _passed_results: Array[_TestScriptResults]
var _total_results_count: int
var _failed_results_count: int
var _passed_results_count: int


func _init(
	configuration_value: _Configuration,
	results_value: Array[_TestScriptResults],
) -> void:
	_configuration = configuration_value
	_all_results = results_value
	_populate_passed_and_failed_results()
	_populate_result_counts()


func _populate_passed_and_failed_results() -> void:
	var new_failed_results: Array[_TestScriptResults] = []
	var new_passed_results: Array[_TestScriptResults] = []

	for script_test_summary in _all_results:
		script_test_summary._populate_passed_and_failed_results()

		var failed_only := script_test_summary.failed_results
		var passed_only := script_test_summary.passed_results

		if failed_only.size() > 0:
			new_failed_results.append(_TestScriptResults.new(script_test_summary.source_file, failed_only))

		if passed_only.size() > 0:
			new_passed_results.append(_TestScriptResults.new(script_test_summary.source_file, passed_only))

	_failed_results = new_failed_results
	_passed_results = new_passed_results


func _populate_result_counts() -> void:
	_total_results_count = 0
	_failed_results_count = 0
	_passed_results_count = 0
	for script_test_summary in _all_results:
		_total_results_count += script_test_summary.all_results.size()
		_failed_results_count += script_test_summary.failed_results.size()
		_passed_results_count += script_test_summary.passed_results.size()
