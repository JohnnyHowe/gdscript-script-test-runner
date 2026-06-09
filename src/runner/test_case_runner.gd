## Runs one discovered test case.
const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestResultStandardizer := preload("./test_result_standardizer.gd")


static func run(test: _TestDataObjects.Test) -> ScriptTestResult:
	var raw_result := test.test_function.call()
	var compiled_result := _TestResultStandardizer.standardize(raw_result)
	compiled_result.test = test
	return compiled_result
