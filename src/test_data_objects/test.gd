var name: String:
	get: return _name

var test_function: Callable:
	get: return _test_function

var file_path: String:
	get: return _file_path

var file_instance: Object:
	get: return _file_instance

var method_name: String:
	get: return _method_name

var _name: String
var _test_function: Callable
var _file_path: String
var _file_instance: Object
var _method_name: String


func _init(
	name_value: String,
	test_function_value: Callable,
	file_path_value: String,
	file_instance_value: Object,
	method_name_value: String
) -> void:
	_name = name_value
	_test_function = test_function_value
	_file_path = file_path_value
	_file_instance = file_instance_value
	_method_name = method_name_value


func _to_string() -> String:
	return "%s<%s from %s.%s>" % [get_script().get_global_name(), _file_path, _method_name]
