const TestCase := preload("res://addons/gdscript-script-test-runner/src/data/tests/test_case.gd")
const TestFileResult := preload("res://addons/gdscript-script-test-runner/src/data/results/test_file_result.gd")
const ExampleTests := preload("res://addons/gdscript-script-test-runner/example/example.tests.gd")


func test_to_dictionary_uses_file_path_key() -> Array[TestCaseResult]:
	var test_case := TestCase.new()
	test_case.file_path = StringName(ExampleTests.resource_path)
	test_case.method_name = "test_one_plus_one_equals_two"

	var test_result := TestCaseResult.succeed()
	test_result.test_case = test_case

	var file_result := TestFileResult.new(ExampleTests, [test_result] as Array[TestCaseResult])
	var dictionary := file_result.to_dictionary()

	var results: Array[TestCaseResult] = []
	results.append(TestCaseResult.from_equals(true, dictionary.has("file_path")))
	results.append(TestCaseResult.from_equals(ExampleTests.resource_path, dictionary.get("file_path")))
	results.append(TestCaseResult.from_equals(false, dictionary.has("source_file")))
	return results
