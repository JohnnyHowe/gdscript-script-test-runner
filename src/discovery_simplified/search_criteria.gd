const TestFilter := preload("../test_filter.gd")


var search_root: String
var test_file_name_suffix: String
var test_function_name_prefix: String
var filter: TestFilter


func _init(
	search_root_value: String = "res://",
	filter_value: TestFilter = null,
	test_file_name_suffix_value := ".tests.gd",
	test_function_name_prefix_value := "test_"
) -> void:
	search_root = search_root_value
	filter = filter_value
	if filter == null:
		filter = TestFilter.new()
	test_file_name_suffix = test_file_name_suffix_value
	test_function_name_prefix = test_function_name_prefix_value


static func from_cli_args(args: Dictionary):
	var ignored_patterns: Array[String] = [
		TestFilter.get_path_ignore_pattern("res://.godot")
	]
	var filter := TestFilter.new(
		args.get("test_file_pattern", ".*"),
		args.get("test_name_pattern", ".*"),
		ignored_patterns
	)
	return new(
		"res://",
		filter,
		".tests.gd",
		"test_"
	)
