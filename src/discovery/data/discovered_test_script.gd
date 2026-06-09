## Data for one discovered test script.
## Groups a GDScript resource with the tests discovered inside it.
const _TestDataObjects := preload("../../test_data_objects/main.gd")
const DiscoveredTest := preload("./discovered_test.gd")

var test_file: GDScript:
	get: return _test_file

var file_path: String:
	get: return _file_path

var tests: Array[DiscoveredTest]:
	get: return _tests

var _test_file: GDScript
var _file_path: String
var _tests: Array[DiscoveredTest]


func _init(test_file_value: GDScript, tests_value: Array[DiscoveredTest]) -> void:
	_test_file = test_file_value
	_file_path = test_file_value.resource_path
	_tests = tests_value


func to_test_script() -> _TestDataObjects.TestScript:
	var executable_tests: Array[_TestDataObjects.Test] = []
	for test in _tests:
		executable_tests.append(test.to_test())
	return _TestDataObjects.TestScript.new(_test_file, executable_tests)


func to_metadata() -> Dictionary:
	var test_metadata: Array[Dictionary] = []
	for test in _tests:
		test_metadata.append(test.to_metadata())
	return {
		"file_path": _file_path,
		"tests": test_metadata
	}
