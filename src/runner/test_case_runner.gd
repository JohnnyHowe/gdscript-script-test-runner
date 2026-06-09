## Runs one discovered test case.
const TestSuite := preload("../discovery/data/test_suite.gd")
const TestCase := TestSuite.TestCase
const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestResultStandardizer := preload("./test_result_standardizer.gd")


static func run(test_case: TestCase, file_instance: Object) -> TestCaseResult:
	var method_name := String(test_case.method_name)
	var raw_result = file_instance.call(method_name)
	var compiled_result := _TestResultStandardizer.standardize(raw_result)
	compiled_result.test = _TestDataObjects.Test.new(
		method_name,
		Callable(file_instance, method_name),
		String(test_case.file_path),
		file_instance,
		method_name
	)
	return compiled_result
