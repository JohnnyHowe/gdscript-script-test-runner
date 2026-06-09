## Runs every discovered test case in one test file.
const TestSuite := preload("../discovery_simplified/data/test_suite.gd")
const TestFile := TestSuite.TestFile
const TestCase := TestSuite.TestCase
const _TestCaseRunner := preload("./test_case_runner.gd")
const _Configuration := preload("../configuration.gd")


static func run(configuration: _Configuration, test_file: TestFile, script: GDScript) -> Array[TestCaseResult]:
	var results: Array[TestCaseResult] = []
	var file_instance := script.new()

	for test_case: TestCase in test_file.cases:
		var result := _TestCaseRunner.run(test_case, file_instance)
		results.append(result)
		if configuration.stop_on_first_failed_test and not result.passed:
			break
	return results
