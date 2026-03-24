const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestRunner := preload("./test_runner.gd")


static func run(test_script: _TestDataObjects.TestScript) -> Array[ScriptTestResult]:
	var results: Array[ScriptTestResult] = []
	for test in test_script.tests:
		results.append(_TestRunner.run(test))
	return results
