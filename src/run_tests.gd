extends SceneTree

const _Configuration := preload("./configuration.gd")
const _Loader := preload("./loader/main.gd")
const _Logging := preload("./logging/main.gd")
const _TestFilter := preload("./test_filter.gd")
const _TestScriptsRunner := preload("./runner/test_scripts_runner.gd")


func _initialize():
	_run()


func _run():
	var args := UserArgumentParser.parse_cmdline_user_args()
	var configuration := _create_configuration(args)

	var test_scripts := _Loader.TestScriptsLoader.new(configuration).load()

	var runner := _TestScriptsRunner.new()
	var results := runner.run(configuration, test_scripts)

	var log_creator := _Logging.Log.new(results)

	var log := log_creator.as_string(args.get("hide_passed_tests", false))

	if not args.get("hide_results", false):
		print(log)

	if args.has("results_file"):
		_Logging.WriteToFile.write(args["results_file"], log)	

	var exit_code := 0 if results.passed else 1
	_quit(exit_code)


func _create_configuration(args: Dictionary) -> _Configuration:

	var ignored_patterns: Array[String] = [
		_TestFilter.get_path_ignore_pattern("res://.godot")
	]
	var filter := _TestFilter.new(
		args.get("test_file_pattern", ".*"),
		args.get("test_name_pattern", ".*"),
		ignored_patterns
	)
	return _Configuration.new(
		"res://",
		filter,
		".tests.gd",
		"test_",
		"_test_generator",
		args.get("fail_fast", false)
	)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
