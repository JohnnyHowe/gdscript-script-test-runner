## Runs every discovered test file and returns the aggregate suite result.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestFile := TestSuite.TestFile
const _TestFileRunner := preload("./test_file_runner.gd")
const _Configuration := preload("../configuration.gd")
const _TestFileResult := preload("../data/results/test_file_result.gd")
const _TestSuiteResult := preload("../data/results/test_suite_result.gd")

func run(configuration: _Configuration, test_suite: TestSuite) -> _TestSuiteResult:
	var file_results: Array[_TestFileResult] = []
	for test_file: TestFile in test_suite.files:
		var script: GDScript = load(String(test_file.file_path))
		var results := _TestFileRunner.run(configuration, test_file, script)
		var file_result := _TestFileResult.new(script, results)
		file_results.append(file_result)
		if configuration.stop_on_first_failed_test and not file_result.passed:
			break
	return _TestSuiteResult.new(configuration, file_results)
