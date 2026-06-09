## Runs every discovered test file and returns the aggregate suite result.
const TestSuite := preload("../discovery_simplified/data/test_suite.gd")
const TestFile := TestSuite.TestFile
const _TestFileRunner := preload("./test_file_runner.gd")
const _Configuration := preload("../configuration.gd")
const _TestScriptResults := preload("../results/test_script_results.gd")
const _TestScriptsResults := preload("../results/test_scripts_results.gd")

func run(configuration: _Configuration, test_suite: TestSuite) -> _TestScriptsResults:
	var script_results: Array[_TestScriptResults] = []
	for test_file: TestFile in test_suite.files:
		var script: GDScript = load(String(test_file.file_path))
		var results := _TestFileRunner.run(configuration, test_file, script)
		var script_result := _TestScriptResults.new(script, results)
		script_results.append(script_result)
		if configuration.stop_on_first_failed_test and not script_result.passed:
			break
	return _TestScriptsResults.new(configuration, script_results)
