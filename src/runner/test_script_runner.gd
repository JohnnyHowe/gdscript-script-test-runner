const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestRunner := preload("./test_runner.gd")
const _Configuration := preload("../configuration.gd")


static func run(configuration: _Configuration, test_script: _TestDataObjects.TestScript) -> Array[ScriptTestResult]:
	var results: Array[ScriptTestResult] = []
	for test in test_script.tests:
		var result := _TestRunner.run(test)
		results.append(result)
		if configuration.stop_on_first_failed_test and not result.passed:
			break
	return results
