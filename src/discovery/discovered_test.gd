## Data for one discovered test callable.
## Includes runtime fields for execution and metadata fields for discovery output.
const _TestDataObjects := preload("../test_data_objects/main.gd")

var name: String:
	get: return _name

var test_function: Callable:
	get: return _test_function

var file_path: String:
	get: return _file_path

var file_instance: Object:
	get: return _file_instance

var source_method_name: String:
	get: return _source_method_name

var kind: String:
	get: return _kind

var line: int:
	get: return _line

var _name: String
var _test_function: Callable
var _file_path: String
var _file_instance: Object
var _source_method_name: String
var _kind: String
var _line: int


func _init(
	name_value: String,
	test_function_value: Callable,
	file_path_value: String,
	file_instance_value: Object,
	source_method_name_value: String,
	kind_value: String,
	line_value: int
) -> void:
	_name = name_value
	_test_function = test_function_value
	_file_path = file_path_value
	_file_instance = file_instance_value
	_source_method_name = source_method_name_value
	_kind = kind_value
	_line = line_value


func to_test() -> _TestDataObjects.Test:
	return _TestDataObjects.Test.new(
		_name,
		_test_function,
		_file_path,
		_file_instance,
		_source_method_name
	)


func to_metadata() -> Dictionary:
	return {
		"file_path": _file_path,
		"name": _name,
		"source_method": _source_method_name,
		"line": _line,
		"kind": _kind
	}
