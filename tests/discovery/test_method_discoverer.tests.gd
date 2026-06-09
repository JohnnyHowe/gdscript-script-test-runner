const _Configuration := preload("res://addons/gdscript-script-test-runner/src/configuration.gd")
const _TestDiscovery := preload("res://addons/gdscript-script-test-runner/src/discovery/test_discovery.gd")
const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")
const _Fixture := preload("./fixtures/discovery_fixture.gd")


func test_discovers_regular_and_generated_tests() -> Array[ScriptTestResult]:
	var discoverer = _create_discoverer(".*")
	var tests: Array = discoverer.discover(_Fixture)
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(3, tests.size()))
	results.append(ScriptTestResult.from_equals("test_generated_a", tests[0].name))
	results.append(ScriptTestResult.from_equals("generated", tests[0].kind))
	results.append(ScriptTestResult.from_equals("sample_test_generator", tests[0].source_method_name))
	results.append(ScriptTestResult.from_equals(5, tests[0].line))
	results.append(ScriptTestResult.from_equals("test_generated_b", tests[1].name))
	results.append(ScriptTestResult.from_equals(5, tests[1].line))
	results.append(ScriptTestResult.from_equals("test_regular", tests[2].name))
	results.append(ScriptTestResult.from_equals("regular", tests[2].kind))
	results.append(ScriptTestResult.from_equals(12, tests[2].line))
	return results


func test_respects_method_filter() -> Array[ScriptTestResult]:
	var discoverer = _create_discoverer("^test_regular$")
	var tests: Array = discoverer.discover(_Fixture)
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(1, tests.size()))
	results.append(ScriptTestResult.from_equals("test_regular", tests[0].name))
	results.append(ScriptTestResult.from_equals(12, tests[0].line))
	return results


func _create_discoverer(method_pattern: String):
	var filter := _TestFilter.new(".*", method_pattern, [] as Array[String])
	var configuration := _Configuration.new(
		"res://",
		filter,
		".tests.gd",
		"test_",
		"_test_generator",
		false
	)
	return _TestDiscovery.TestMethodDiscoverer.new(configuration)
