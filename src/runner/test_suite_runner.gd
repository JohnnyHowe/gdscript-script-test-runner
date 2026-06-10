## Runs every discovered test file and returns the aggregate suite result.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestFile := TestSuite.TestFile
const TestFileRunner := preload("./test_file_runner.gd")
const TestFileResult := preload("../data/results/test_file_result.gd")
const TestSuiteResult := preload("../data/results/test_suite_result.gd")

func run(test_suite: TestSuite) -> TestSuiteResult:
	var file_results: Array[TestFileResult] = []
	for test_file: TestFile in test_suite.files:
		var script: GDScript = load(String(test_file.file_path))
		var results := TestFileRunner.run(test_file, script)
		var file_result := TestFileResult.new(script, results)
		file_results.append(file_result)
	return TestSuiteResult.new(file_results)
