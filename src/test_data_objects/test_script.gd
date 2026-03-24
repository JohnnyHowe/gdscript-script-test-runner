const _TestDataObjects := preload("../test_data_objects/main.gd")

var test_file: GDScript:
	get: return _test_file

var tests: Array[_TestDataObjects.Test]:
	get: return _tests

var _test_file: GDScript
var _tests: Array[_TestDataObjects.Test]


func _init(test_file_value: GDScript, tests_value: Array[_TestDataObjects.Test]) -> void:
	_test_file = test_file_value
	_tests = tests_value
