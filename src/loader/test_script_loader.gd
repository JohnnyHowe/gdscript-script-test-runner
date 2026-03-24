const _TestDataObjects := preload("../test_data_objects/main.gd")
const _Configuration := preload("../configuration.gd")
const _TestMethodLoader := preload("./test_method_loader.gd")

var _configuration: _Configuration
var _method_loader: _TestMethodLoader


func _init(configuration: _Configuration) -> void:
	_configuration = configuration
	_method_loader = _TestMethodLoader.new(configuration)

func load(test_file: GDScript) -> _TestDataObjects.TestScript:
	var tests := _get_tests_in_file(test_file)
	return _TestDataObjects.TestScript.new(test_file, tests)


func _get_tests_in_file(test_file: GDScript) -> Array[_TestDataObjects.Test]:
	var tests: Array[_TestDataObjects.Test] = []
	var file_instance = test_file.new()

	for method_dict in file_instance.get_method_list():
		if _configuration.filter.should_ignore_method(method_dict["name"]):
			continue

		tests += _method_loader.load(file_instance, test_file.resource_path, method_dict)

	return tests
