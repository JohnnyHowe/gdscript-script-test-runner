extends SceneTree

const _Configuration := preload("./configuration.gd")
const _TestDiscovery := preload("./discovery/test_discovery.gd")
const _TestFilter := preload("./test_filter.gd")


func _initialize():
	_run()


func _run():
	var args := UserArgumentParser.parse_cmdline_user_args()
	var configuration := _create_configuration(args)
	var discovery := _TestDiscovery.new(configuration)
	var test_scripts := discovery.discover()
	var json := _TestDiscovery.DiscoveryJsonWriter.to_json(test_scripts)

	if args.has("results_file"):
		_TestDiscovery.DiscoveryJsonWriter.write(args["results_file"], test_scripts)

	if not args.get("hide_results", false):
		print(json)

	_quit(0)


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
		false
	)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
