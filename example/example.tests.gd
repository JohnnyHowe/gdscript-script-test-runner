
## Run with following command
## godot --headless -s addons/gdscript-script-test-runner/src/run_tests.gd -- test_file_pattern=example/example.tests.gd test_name_pattern=test_one_plus_one_equals_two hide_passed_tests=false
func test_one_plus_one_equals_two() -> TestCaseResult:
	var expected := 2
	var actual := 1 + 1
	return TestCaseResult.from_equals(expected, actual)
