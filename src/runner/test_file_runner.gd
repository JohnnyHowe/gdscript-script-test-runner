## Runs every discovered test case in one test file.
const TestSuite := preload("../data/tests/test_suite.gd")
const TestFile := TestSuite.TestFile
const TestCase := TestSuite.TestCase
const TestCaseRunner := preload("./test_case_runner.gd")


static func run(test_file: TestFile, script: GDScript, root: Node = null, log_capture = null) -> Array[TestCaseResult]:
	var results: Array[TestCaseResult] = []
	var file_instance := script.new()

	if file_instance is Node and root != null:
		root.add_child(file_instance)

	for test_case: TestCase in test_file.cases:
		var result := TestCaseRunner.run(test_case, file_instance, log_capture)
		results.append(result)

	if file_instance is Node:
		if file_instance.get_parent() != null:
			file_instance.get_parent().remove_child(file_instance)
		file_instance.free()

	return results
