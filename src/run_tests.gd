extends SceneTree

const SearchCriteria := preload("./discovery/search_criteria.gd")
const TestDiscovery := preload("./discovery/test_discovery.gd")

const CliHelpers := preload("./cli_helpers/cli_helpers.gd")

const TestFilter := preload("./test_filter.gd")
const TestSuiteRunner := preload("./runner/test_suite_runner.gd")
const TestSuite := preload("./data/tests/test_suite.gd")

const MarkdownOutputGenerator := preload("./result_parsing/result_markdown_generator.gd")
const ConsoleOutputGenerator := preload("./result_parsing/console_output_generator.gd")


class LogCapture:
	var enabled := false
	var log_path := ""
	var start_position := 0


	func _init() -> void:
		var file_logging_enabled := ProjectSettings.get_setting("debug/file_logging/enable_file_logging", true)
		if not file_logging_enabled:
			return

		var configured_path := String(ProjectSettings.get_setting("debug/file_logging/log_path", "user://logs/godot.log"))
		log_path = ProjectSettings.globalize_path(configured_path)
		enabled = FileAccess.file_exists(log_path)
		if enabled:
			start_position = _get_log_content_length()


	func begin_test() -> void:
		if not enabled:
			return

		start_position = _get_log_content_length()


	func end_test() -> String:
		if not enabled:
			return ""

		var length := _get_log_content_length()
		if start_position >= length:
			return ""

		var file := FileAccess.open(log_path, FileAccess.READ)
		if file == null:
			enabled = false
			return ""

		file.seek(start_position)
		var logs := file.get_buffer(length - start_position).get_string_from_utf8()
		start_position = length
		return logs


	func _get_log_content_length() -> int:
		var file := FileAccess.open(log_path, FileAccess.READ)
		if file == null:
			enabled = false
			return 0

		var contents := file.get_buffer(file.get_length())
		for i in contents.size():
			if contents[i] == 0:
				return i

		return contents.size()


class Args:
	# Custom Test Suite
	var use_test_suite_file: bool
	var test_suite_file: StringName

	# Discovery
	var test_file_pattern: String
	var test_method_pattern: String

	# Output
	var use_results_file_json: bool
	var results_file_json: StringName
	var use_results_file_md: bool
	var results_file_md: StringName
	var print_to_console: bool


func _initialize():
	_run()


func _run():
	var args := _parse_args()

	var test_suite := _get_test_suite(args)
	if test_suite == null:
		_quit(1)
		return

	var runner := TestSuiteRunner.new()
	var log_capture := LogCapture.new()
	var results := await runner.run(test_suite, log_capture)

	if args.print_to_console:
		var output_generator := ConsoleOutputGenerator.new(results)
		var output_string := output_generator.as_string()
		print(output_string)

	if args.use_results_file_json:
		var results_dictionary := results.to_dictionary()
		var results_json := JSON.stringify(results_dictionary, "\t")
		CliHelpers.WriteToFile.write(args.results_file_json, results_json)

	if args.use_results_file_md:
		var results_markdown: String = MarkdownOutputGenerator.new(results).as_string()
		CliHelpers.WriteToFile.write(args.results_file_md, results_markdown)

	var exit_code := 0 if results.passed else 1
	_quit(exit_code)


func _parse_args() -> Args:
	var args := UserArgumentParser.parse_cmdline_user_args()
	var parsed_args := Args.new()

	parsed_args.use_test_suite_file = args.has("test_suite_file")
	parsed_args.test_suite_file = args.get("test_suite_file", "")

	parsed_args.use_results_file_json = args.has("results_file_json")
	parsed_args.results_file_json = args.get("results_file_json", "")

	parsed_args.use_results_file_md = args.has("results_file_md")
	parsed_args.results_file_md = args.get("results_file_md", "")

	parsed_args.print_to_console = args.get("print_to_console", true)

	parsed_args.test_file_pattern = args.get("test_file_pattern", ".*")
	parsed_args.test_method_pattern = args.get("test_method_pattern", ".*")

	return parsed_args


func _get_test_suite(args: Args) -> TestSuite:
	if args.use_test_suite_file:
		return CliHelpers.load_test_suite(args.test_suite_file)

	var search_criteria := _create_search_criteria(args)
	return TestDiscovery.new(search_criteria).discover()


func _create_search_criteria(args: Args) -> SearchCriteria:
	var search_criteria := SearchCriteria.new()
	search_criteria.filter = _create_search_filter(args)
	return search_criteria
	

func _create_search_filter(args: Args) -> SearchCriteria.TestFilter:
	return SearchCriteria.TestFilter.new(
		args.test_file_pattern,
		args.test_method_pattern,
	)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
