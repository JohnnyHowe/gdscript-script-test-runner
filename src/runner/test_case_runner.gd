## Runs one discovered test case.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestCase := TestSuite.TestCase
const TestResultStandardizer := preload("./test_result_standardizer.gd")


static func run(test_case: TestCase, file_instance: Object, log_capture = null) -> TestCaseResult:
	var method_name := String(test_case.method_name)
	if log_capture != null:
		log_capture.begin_test()
	var raw_result = file_instance.call(method_name)
	var logs := ""
	if log_capture != null:
		logs = log_capture.end_test()
	var compiled_result := TestResultStandardizer.standardize(raw_result)
	compiled_result.test_case = test_case
	compiled_result.logs = logs
	return compiled_result
