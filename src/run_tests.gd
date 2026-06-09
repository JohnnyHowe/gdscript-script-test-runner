extends SceneTree

const SearchCriteria := preload("./discovery/search_criteria.gd")
const TestDiscovery := preload("./discovery/test_discovery.gd")
const Logging := preload("./logging/main.gd")
const TestFilter := preload("./test_filter.gd")
const TestSuiteRunner := preload("./runner/test_suite_runner.gd")


func _initialize():
	_run()


func _run():
	var args := UserArgumentParser.parse_cmdline_user_args()

	var test_suite := TestDiscovery.new(SearchCriteria.from_cli_args(args)).discover()

	var runner := TestSuiteRunner.new()
	var results := runner.run(test_suite)

	var log_creator := Logging.Log.new(results)
	
	var log := log_creator.as_string(args.get("hide_passed_tests", false))

	if not args.get("hide_results", false):
		print(log)

	if args.has("results_file"):
		Logging.WriteToFile.write(args["results_file"], log)	

	var exit_code := 0 if results.passed else 1
	_quit(exit_code)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
