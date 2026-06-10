extends SceneTree

const SearchCriteria := preload("./search_criteria.gd")
const TestDiscovery := preload("./test_discovery.gd")


func _initialize():
	_run()


func _run():
	var args := UserArgumentParser.parse_cmdline_user_args()
	var search_criteria = SearchCriteria.from_cli_args(args)
	var suite = TestDiscovery.new(search_criteria).discover()
	var json := JSON.stringify(suite.to_dictionary(), "\t")

	if args.has("results_file"):
		_write_json(args["results_file"], json)

	if not args.get("hide_results", false):
		print(json)

	_quit(0)


func _write_json(path: String, json: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write discovery results to %s" % path)
		_quit(1)
		return
	file.store_string(json)


func _quit(exit_code: int):
	for child in root.get_children():
		child.free()
	quit(exit_code)
