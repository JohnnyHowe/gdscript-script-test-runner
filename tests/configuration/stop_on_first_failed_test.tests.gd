const _Configuration := preload("../../src/configuration.gd")


func test_stop_on_first_failed_test_defaults_to_false() -> ScriptTestResult:
	var configuration := _Configuration.new()
	return ScriptTestResult.from_equals(false, configuration.stop_on_first_failed_test)


func test_stop_on_first_failed_test_can_be_enabled() -> ScriptTestResult:
	var configuration := _Configuration.new("res://", null, ".tests.gd", "test_", "_test_generator", true)
	return ScriptTestResult.from_equals(true, configuration.stop_on_first_failed_test)
