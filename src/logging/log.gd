const _TestScriptsResults := preload("../results/test_scripts_results.gd")
const _TestScriptResults := preload("../results/test_script_results.gd")
const _SECTION_SEPARATOR := "================================================================"

var _results: _TestScriptsResults
var _lines: Array[String]


func _init(results: _TestScriptsResults) -> void:
	_results = results


func as_string(hide_passed: bool = false) -> String:
	_build_lines(hide_passed)
	return "\n".join(_lines)


func _build_lines(hide_passed: bool) -> void:
	_lines = []
	_append_section_header("Test Results")
	_lines.append("Total: %s, Passed: %s, Failed: %s" % [
		_results.total_results_count,
		_results.passed_results_count,
		_results.failed_results_count
	])

	_append_section_header("All Results")
	for script_result in _results.all_results:
		var file_path: String = script_result.source_file.resource_path.trim_prefix("res://")
		var total_count: int = script_result.all_results.size()
		var passed_count: int = script_result.passed_results.size()
		if hide_passed and passed_count == total_count:
			continue
		_lines.append("")
		_lines.append("File: %s (%s/%s)" % [file_path, passed_count, total_count])
		_append_test_script_result(script_result, hide_passed)

	_append_section_header("Failing Tests")
	if _results.failed_results.size() == 0:
		_lines.append("No tests failed.")
	for script_result in _results.failed_results:
		var file_path: String = script_result.source_file.resource_path.trim_prefix("res://")
		_lines.append("")
		_lines.append("File: %s" % [file_path])
		_append_test_script_result(script_result, false)


func _append_section_header(title: String) -> void:
	_lines.append("")
	_lines.append(title)
	_lines.append(_SECTION_SEPARATOR)


func _append_test_script_result(script_results: _TestScriptResults, hide_passed: bool) -> void:
	for result in script_results.all_results:
		if hide_passed and result.passed:
			continue
		_lines.append("- %s" % result.get_display_string())
