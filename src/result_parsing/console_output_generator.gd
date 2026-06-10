const TestSuiteResult := preload("../data/results/test_suite_result.gd")
const TestFileResult := TestSuiteResult.TestFileResult
const TestCaseResult := TestFileResult.TestCaseResult

const HEADER_SEPARATOR: String = "===================================================================================================="

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
		_generate_main(),
		"",
		_generate_summary_string(),
		"",
	])


func _generate_summary_string() -> String:
	return "\n".join([
		"Summary",
		HEADER_SEPARATOR,
		"Total:  %s cases across %s files" % [_all_case_results.size(), _result.all_results.size()],
		"Passed: %s cases across %s files " % [_passed_case_results.size(), _result.passed_results.size()],
		"Failed: %s cases across %s files" % [_failed_case_results.size(), _result.failed_results.size()],
	])


func _generate_main() -> String:
	var lines: Array[String] = []

	for file_result: TestFileResult in _result.all_results:
		if not file_result.passed:
			lines.append("\n\n" + _generate_section_for_file(file_result))

	return "\n".join(lines)


func _generate_section_for_file(file_result: TestFileResult) -> String:
	var lines: Array[String] = [
		file_result.source_file.resource_path,
		"-".repeat(file_result.source_file.resource_path.length()),
		_indent_all_lines(_generate_summary_section_for_file(file_result)),
		"",
		_indent_all_lines(_generate_failed_section_for_file(file_result))
	]

	return "\n".join(lines)


static func _generate_summary_section_for_file(file_result: TestFileResult) -> String:
	return "Summary: %s passed, %s failed" % [file_result.passed_results.size(), file_result.failed_results.size()]


static func _generate_failed_section_for_file(file_result: TestFileResult) -> String:
	var parts: Array[String] = []
	for case_result in file_result.failed_results:
		parts.append(_generate_failed_case_string(case_result))
	return "\n\n".join(parts)


static func _generate_failed_case_string(case_result: TestCaseResult) -> String:
	return "\n".join([
		case_result.test_case.method_name,
		"(%s:%s)" % [case_result.test_case.file_path, case_result.test_case.line_number],
		_clean_and_indent_failed_message(case_result.message)
	])


static func _clean_and_indent_failed_message(message: String) -> String:
	return _prefix_all_lines("\t| ", message.strip_edges())


static func _indent_all_lines(text: String, indent := "\t") -> String:
	return _prefix_all_lines(indent, text)


static func _prefix_all_lines(prefix: String, text: String) -> String:
	return prefix + text.replace("\n", "\n" + prefix)


#endregion
