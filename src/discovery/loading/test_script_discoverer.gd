## Discovers tests inside one GDScript test file.
## Regular test methods become one discovered test; generator methods produce generated tests.
const _Configuration := preload("../../configuration.gd")
const DiscoveredTest := preload("../data/discovered_test.gd")
const GDScriptMethodLineIndex := preload("../parsing/gdscript_method_line_index.gd")

const REGULAR_TEST_KIND := "regular"
const GENERATED_TEST_KIND := "generated"

var _configuration: _Configuration


func _init(configuration: _Configuration) -> void:
	_configuration = configuration


func discover(test_file: GDScript) -> Array[DiscoveredTest]:
	var tests: Array[DiscoveredTest] = []
	var file_instance = test_file.new()
	var methods: Array = file_instance.get_method_list()
	var method_lines := GDScriptMethodLineIndex.get_method_lines(test_file.resource_path)
	methods.sort_custom(func(a: Dictionary, b: Dictionary): return a["name"] < b["name"])

	for method_dict in methods:
		var method_name: String = method_dict["name"]
		if _configuration.filter.should_ignore_method(method_name):
			continue

		tests += _discover_method(file_instance, test_file.resource_path, method_name, method_lines.get(method_name, GDScriptMethodLineIndex.UNKNOWN_LINE))

	return tests


func _discover_method(file_instance, file_path: String, method_name: String, line: int) -> Array[DiscoveredTest]:
	if method_name.begins_with(_configuration.test_function_name_prefix):
		return [_create_regular_test(file_instance, file_path, method_name, line)]

	if method_name.ends_with(_configuration.test_generator_name_postfix):
		return _create_generated_tests(file_instance, file_path, method_name, line)

	return []


func _create_regular_test(file_instance, file_path: String, method_name: String, line: int) -> DiscoveredTest:
	return DiscoveredTest.new(
		method_name,
		func(): return file_instance.call(method_name),
		file_path,
		file_instance,
		method_name,
		REGULAR_TEST_KIND,
		line
	)


func _create_generated_tests(file_instance, file_path: String, method_name: String, line: int) -> Array[DiscoveredTest]:
	var tests: Array[DiscoveredTest] = []
	var generated_tests: Dictionary[String, Callable] = file_instance.call(method_name)
	var test_names: Array = generated_tests.keys()
	test_names.sort()

	for test_name in test_names:
		var test_callable: Callable = generated_tests[test_name]
		tests.append(DiscoveredTest.new(
			test_name,
			test_callable,
			file_path,
			file_instance,
			method_name,
			GENERATED_TEST_KIND,
			line
		))

	return tests
