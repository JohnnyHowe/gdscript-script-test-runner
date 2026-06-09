## Runs every discovered test case in one test file.
const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestCaseRunner := preload("./test_case_runner.gd")
const _Configuration := preload("../configuration.gd")


static func run(configuration: _Configuration, test_script: _TestDataObjects.TestScript) -> Array[ScriptTestResult]:
	var results: Array[ScriptTestResult] = []
	for test: _TestDataObjects.Test in test_script.tests:
		var result := _TestCaseRunner.run(test)
		results.append(result)
		if configuration.stop_on_first_failed_test and not result.passed:
			break
	return results
