const _Configuration := preload("../../src/configuration.gd")


func test_stop_on_first_failed_test_defaults_to_false() -> TestCaseResult:
	var configuration := _Configuration.new()
	return TestCaseResult.from_equals(false, configuration.stop_on_first_failed_test)


func test_stop_on_first_failed_test_can_be_enabled() -> TestCaseResult:
	var configuration := _Configuration.new("res://", null, ".tests.gd", "test_", "_test_generator", true)
	return TestCaseResult.from_equals(true, configuration.stop_on_first_failed_test)
