## Runs every discovered test case in one test file.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestFile := TestSuite.TestFile
const TestCase := TestSuite.TestCase
const TestCaseRunner := preload("./test_case_runner.gd")


static func run(test_file: TestFile, script: GDScript, log_capture = null) -> Array[TestCaseResult]:
	var results: Array[TestCaseResult] = []
	var file_instance := script.new()

	for test_case: TestCase in test_file.cases:
		var result := await TestCaseRunner.run(test_case, file_instance, log_capture)
		results.append(result)
	return results
