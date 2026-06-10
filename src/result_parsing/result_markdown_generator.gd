const TestSuiteResult := preload("../data/results/test_suite_result.gd")
const TestFileResult := TestSuiteResult.TestFileResult
const TestCaseResult := TestFileResult.TestCaseResult

var _result: TestSuiteResult

var _all_case_results: Array[TestCaseResult]
var _passed_case_results: Array[TestCaseResult]
var _failed_case_results: Array[TestCaseResult]


func _init(result: TestSuiteResult) -> void:
	_result = result
	_setup()

#region Organising

func _setup() -> void:
	_generate_collated_cases()

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

#endregion
#region String Generation

func as_string() -> String:
	return "\n".join([
		_generate_summary_string(),
		"# Failed Files",
		_generate_files_section(false, true),
		"# Passed Files",
		_generate_files_section(true, false)
	])


func _generate_summary_string() -> String:
	return "\n".join([
		"# Summary",
		"| Key | Cases | Files |",
		"| - | - | - |",
		"| Total | %s | %s |" % [_all_case_results.size(), _result._all_results.size()],
		"| Passed | %s | %s |" % [_passed_case_results.size(), _result.passed_results.size()],
		"| Failed | %s | %s |" % [_failed_case_results.size(), _result.failed_results.size()],
	])


func _generate_files_section(include_passed: bool = true, include_failed: bool = true) -> String:
	var lines: Array[String] = []

	for file_result: TestFileResult in _result.all_results:
		if file_result.passed and include_passed:
			lines.append(_generate_section_for_file(file_result))
		if not file_result.passed and include_failed:
			lines.append(_generate_section_for_file(file_result))

	return "\n".join(lines)


func _generate_section_for_file(file_result: TestFileResult) -> String:
	var lines: Array[String] = [
		"### %s" % [_resource_path_to_relative_link(file_result.source_file.resource_path)],
		"| Passed | Test Name | Failure Reason |",
		"| - | - | - |",
	]

	for case_result in file_result.all_results:
		var passed_string := "✅" if case_result.passed else "❌"
		var failure_message_string := "" if case_result.passed else case_result.message
		var line := "| %s | `%s` | %s |" % [passed_string, case_result.test_case.method_name, failure_message_string]
		lines.append(line)

	return "\n".join(lines)


static func _resource_path_to_relative_link(resource_path: String) -> String:
	return "[`%s`](%s)" % [resource_path, _resource_path_to_relative_path(resource_path)]


static func _resource_path_to_relative_path(resource_path: String) -> String:
	if resource_path.begins_with("res://"):
		return resource_path.trim_prefix("res://")
	return resource_path


#endregion
