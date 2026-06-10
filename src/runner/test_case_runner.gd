## Runs one discovered test case.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestCase := TestSuite.TestCase
const TestResultStandardizer := preload("./test_result_standardizer.gd")


static func run(test_case: TestCase, file_instance: Object) -> TestCaseResult:
	var method_name := String(test_case.method_name)
	var raw_result = file_instance.call(method_name)
	var compiled_result := TestResultStandardizer.standardize(raw_result)
	compiled_result.test_case = test_case
	return compiled_result
