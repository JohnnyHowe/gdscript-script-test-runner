const _TestDataObjects := preload("../test_data_objects/main.gd")
const _Configuration := preload("../configuration.gd")

var _configuration: _Configuration


func _init(configuration: _Configuration) -> void:
	_configuration = configuration


func load(file_instance, file_path, method_dict: Dictionary) -> Array[_TestDataObjects.Test]:
	var method_name: String = method_dict["name"]

	if method_name.begins_with(_configuration.test_function_name_prefix):
		return _get_regular_tests_from_method(file_instance, file_path, method_name)

	if method_name.ends_with(_configuration.test_generator_name_postfix):
		return _get_generator_tests_from_method(file_instance, file_path, method_name)

	return []


func _get_regular_tests_from_method(file_instance, file_path, method_name: String) -> Array[_TestDataObjects.Test]:
	var test := _TestDataObjects.Test.new(
		method_name,
		func(): return file_instance.call(method_name),
		file_path,
		file_instance,
		method_name
	)
	return [test]


func _get_generator_tests_from_method(file_instance, file_path, method_name: String) -> Array[_TestDataObjects.Test]:
	var tests: Array[_TestDataObjects.Test] = []

	var generated_tests: Dictionary[String, Callable] = file_instance.call(method_name)
	for test_name in generated_tests.keys():
		var test_callable: Callable = generated_tests[test_name]
		var test := _TestDataObjects.Test.new(
			test_name,
			test_callable,
			file_path,
			file_instance,
			method_name
		)
		tests.append(test)

	return tests
