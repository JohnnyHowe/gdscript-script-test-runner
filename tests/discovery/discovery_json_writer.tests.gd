const _Configuration := preload("res://addons/gdscript-script-test-runner/src/configuration.gd")
const _TestDiscovery := preload("res://addons/gdscript-script-test-runner/src/discovery/test_discovery.gd")
const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")
const _Fixture := preload("./fixtures/discovery_fixture.gd")


func test_json_writer_outputs_metadata_without_runtime_objects() -> Array[ScriptTestResult]:
	var configuration := _Configuration.new(
		"res://",
		_TestFilter.new(".*", ".*", [] as Array[String]),
		".tests.gd",
		"test_",
		"_test_generator",
		false
	)
	var tests: Array = _TestDiscovery.TestMethodDiscoverer.new(configuration).discover(_Fixture)
	var test_scripts: Array = [
		_TestDiscovery.DiscoveredTestScript.new(_Fixture, tests)
	]
	var dictionary := _TestDiscovery.DiscoveryJsonWriter.to_dictionary(test_scripts)
	var first_script = dictionary["test_scripts"][0]
	var first_test = first_script["tests"][0]
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(3, dictionary["tests_found"]))
	results.append(ScriptTestResult.from_equals("res://addons/gdscript-script-test-runner/tests/discovery/fixtures/discovery_fixture.gd", first_script["file_path"]))
	results.append(ScriptTestResult.from_equals(true, first_test.has("file_path")))
	results.append(ScriptTestResult.from_equals(true, first_test.has("name")))
	results.append(ScriptTestResult.from_equals(true, first_test.has("source_method")))
	results.append(ScriptTestResult.from_equals(true, first_test.has("line")))
	results.append(ScriptTestResult.from_equals(5, first_test["line"]))
	results.append(ScriptTestResult.from_equals(true, first_test.has("kind")))
	results.append(ScriptTestResult.from_equals(false, first_test.has("test_function")))
	results.append(ScriptTestResult.from_equals(false, first_test.has("file_instance")))
	return results
