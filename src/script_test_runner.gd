class_name ScriptTestRunner

const TEST_FILE_NAME_POSTFIX := ".tests.gd"
const TEST_FUNCTION_NAME_PREFIX := "test_"

var _root_path: String

var filter := ScriptTestFilter.new()
var assert_on_fail := false
var show_passed_tests := false
var show_unfiltered_test_files := false

var test_files: Array[GDScript]
var _all_test_results: Dictionary[GDScript, Array]


func _init(root_search_path: String) -> void:
	_root_path = root_search_path


func run():
	_load_test_files()

	var line_separator := "\n  - "
	print(line_separator.join([
		"Found %s test files:" % test_files.size(),
		"Test files must end with \"%s\"" % [TEST_FILE_NAME_POSTFIX],
		filter.to_string_with_separator(line_separator)
	]))

	_run_loaded_test_files()
	_print_results()


func _load_test_files():
	test_files = []
	var found_test_files = BetterResourceLoader.get_all_resources_in_folder_recursive(_root_path, _is_test_script)

	if found_test_files.size() == 0:
		push_warning("Found zero files ending with %s" % TEST_FILE_NAME_POSTFIX)
	elif show_unfiltered_test_files:
		var test_file_paths = found_test_files.values().map(func(resource: Resource): return resource.resource_path.trim_prefix("res://"))
		print("\n  - ".join(["Found %s test files (without filter):" % found_test_files.size()] + test_file_paths))

	for test_file in found_test_files.values():
		if not filter.ignore_file(test_file.resource_path):
			test_files.append(test_file)

	if test_files.size() == 0:
		push_warning("Found zero files matching filters.")


func _run_loaded_test_files():
	_all_test_results = {}
	var results_to_show: int = 0
	for test_file: GDScript in test_files:
		var results := run_test_file(test_file)
		_all_test_results[test_file] = results


func _print_results():
	print("=".repeat(80))
	print("Test Results Start")
	for test_file in test_files:
		var results = _all_test_results[test_file]
		if not show_passed_tests:
			results = results.filter(func(result: ScriptTestResult): return result)

		if results.size() == 0:
			continue

		_print_file_results(test_file, results)

	print()
	print()
	print_summary()
	print("Test Results End")
	print("=".repeat(80))


func _print_file_results(test_file: GDScript, results: Array[ScriptTestResult]):
	var results_to_show: Array[ScriptTestResult] = results
	if not show_passed_tests:
		results_to_show = results_to_show.filter(func(result: ScriptTestResult): return not result.passed)

	if results_to_show.size() == 0:
		return

	print(test_file.resource_path.trim_prefix("res://"))
	for result in results_to_show:
		print(result.get_display_string().replace("\n", "\n    "))


func run_test_file(test_file: GDScript) -> Array[ScriptTestResult]:
	var results: Array[ScriptTestResult] = []
	for test in _get_tests_in_file(test_file):
		results.append(test.run_test())
	return results


func _get_tests_in_file(test_file: GDScript) -> Array[ScriptTest]:
	var tests: Array[ScriptTest] = []
	var file_instance = test_file.new()

	for method_dict in file_instance.get_method_list():
		if filter.ignore_method(method_dict["name"]):
			continue

		tests += _get_tests_from_method(file_instance, test_file.resource_path, method_dict)

	return tests


func _get_tests_from_method(file_instance, file_path, method_dict: Dictionary) -> Array[ScriptTest]:
	var method_name: String = method_dict["name"]

	if method_name.begins_with("test_"):
		var test := ScriptTest.new()
		test.name = method_name
		test.test_function = func(): return file_instance.call(test.name)
		test.file_path = file_path
		test.file_instance = file_instance
		test.method_name = method_name
		return [test]

	if method_name.ends_with("_test_generator"):
		var tests: Array[ScriptTest] = []

		var generated_tests: Dictionary[String, Callable] = file_instance.call(method_name)
		for test_name in generated_tests.keys():
			var test_callable: Callable = generated_tests[test_name]
			var test := ScriptTest.new()
			test.name = test_name
			test.test_function = test_callable
			test.file_path = file_path
			test.file_instance = file_instance
			test.method_name = method_name
			tests.append(test)

		return tests

	return []


func print_summary():
	var failed_tests_count = 0

	var tests_run = 0
	for results in _all_test_results.values():
		for result in results:
			tests_run += 1
			if not result.passed:
				failed_tests_count += 1

	if failed_tests_count > 0:
		print("Failed %s/%s tests" % [failed_tests_count, tests_run])
	else:
		print("Passed all tests (%s tests in %s files)" % [tests_run, test_files.size()])


func get_failed_test_count() -> int:
	var failed_tests_count := 0
	for results in _all_test_results.values():
		for result in results:
			if not result.passed:
				failed_tests_count += 1
	return failed_tests_count


static func _is_test_script(resource: Resource) -> bool:
	return resource.resource_path.ends_with(TEST_FILE_NAME_POSTFIX)


## Given the text output printed from this, are all the tests passed?
static func is_full_output_text_a_pass(text: String) -> bool:
	var lines = text.strip_edges().split("\n")
	var last_line: String = lines[lines.size() - 1]
	return not last_line.to_lower().contains("failed")
