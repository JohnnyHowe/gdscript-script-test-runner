const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestScriptRunner := preload("./test_script_runner.gd")
const _Configuration := preload("../configuration.gd")
const _TestScriptResults := preload("../results/test_script_results.gd")
const _TestScriptsResults := preload("../results/test_scripts_results.gd")

func run(configuration: _Configuration, test_scripts: Array[_TestDataObjects.TestScript]) -> _TestScriptsResults:
	var script_results: Array[_TestScriptResults] = []
	for test_script: _TestDataObjects.TestScript in test_scripts:
		var results := _TestScriptRunner.run(configuration, test_script)
		var script_result := _TestScriptResults.new(test_script.test_file, results)
		script_results.append(script_result)
		if configuration.stop_on_first_failed_test and not script_result.passed:
			break
	return _TestScriptsResults.new(configuration, script_results)
