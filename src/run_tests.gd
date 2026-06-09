extends SceneTree

const SearchCriteria := preload("./discovery/search_criteria.gd")
const TestDiscovery := preload("./discovery/test_discovery.gd")
const CliHelpers := preload("./cli_helpers/cli_helpers.gd")
const TestFilter := preload("./test_filter.gd")
const TestSuiteRunner := preload("./runner/test_suite_runner.gd")
const TestSuite := preload("./data/tests/test_suite.gd")


func _initialize():
	_run()


func _run():
	var args := UserArgumentParser.parse_cmdline_user_args()

	var hide_passed_tests: bool = args.get("hide_passed_tests", true)
	var hide_results: bool = args.get("hide_results", false)
	var results_file: StringName = args.get("results_file", "")

	var test_suite := _get_test_suite_from_cli_args(args)

	if test_suite == null:
		_quit(1)
		return

	var runner := TestSuiteRunner.new()
	var results := runner.run(test_suite)

	# var log_creator := CliHelpers.Log.new(results)
	
	# var log := log_creator.as_string(hide_passed_tests)

	var results_dictionary := results.to_dictionary()
	var results_json := JSON.stringify(results_dictionary, "\t")

	if not hide_results:
		print(results_json)

	if not results_file.is_empty():
		CliHelpers.WriteToFile.write(results_file, results_json)

	var exit_code := 0 if results.passed else 1
	_quit(exit_code)


func _get_test_suite_from_cli_args(args: Dictionary) -> TestSuite:
	var test_suite_file_path: StringName = args.get("test_suite_file", "")

	if test_suite_file_path.is_empty():
		var search_criteria: SearchCriteria = SearchCriteria.from_cli_args(args)
		return TestDiscovery.new(search_criteria).discover()
	
	return _load_test_suite(test_suite_file_path)


func _load_test_suite(path: StringName) -> TestSuite:
	if path.is_empty():
		return null
	if not FileAccess.file_exists(path):
		push_error("Test suite path (%s) does not exist!" % [path])
		return null

	var contents := FileAccess.get_file_as_string(path)

	var parser := JSON.new()
	var err := parser.parse(contents)

	if err != OK:
		push_error("Test suite (%s) json parse failed! error=\"%s\"" % [path, parser.get_error_message()])
		return null

	return TestSuite.from_dictionary(parser.data)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
