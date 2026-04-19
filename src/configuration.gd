const _TestFilter := preload("./test_filter.gd")

var test_file_name_postfix: String:
	get: return _test_file_name_postfix

var test_function_name_prefix: String:
	get: return _test_function_name_prefix

var test_generator_name_postfix: String:
	get: return _test_generator_name_postfix

var filter: _TestFilter:
	get: return _filter

var search_root: String:
	get: return _search_root

var stop_on_first_failed_test: bool:
	get: return _stop_on_first_failed_test

var _test_file_name_postfix: String
var _test_function_name_prefix: String
var _test_generator_name_postfix: String
var _filter: _TestFilter
var _search_root: String
var _stop_on_first_failed_test: bool


func _init(
	search_root_value: String = "res://",
	filter_value: _TestFilter = null,
	test_file_name_postfix_value := ".tests.gd",
	test_function_name_prefix_value := "test_",
	test_generator_name_postfix_value := "_test_generator",
	stop_on_first_failed_test_value := false
) -> void:
	_test_file_name_postfix = test_file_name_postfix_value
	_test_function_name_prefix = test_function_name_prefix_value
	_test_generator_name_postfix = test_generator_name_postfix_value
	_filter = filter_value
	if _filter == null:
		_filter = _TestFilter.new()
	_search_root = search_root_value
	_stop_on_first_failed_test = stop_on_first_failed_test_value
