class_name ScriptTestFilter

var _file_filter_pattern: String
var _method_filter_pattern: String
var _file_filter = RegEx.new()
var _method_filter = RegEx.new()


func _init(file_filter_pattern := ".*", method_filter_pattern := ".*") -> void:
	_file_filter_pattern = file_filter_pattern
	_method_filter_pattern = method_filter_pattern
	_file_filter.compile(_file_filter_pattern)
	_method_filter.compile(_method_filter_pattern)


func ignore_file(file_path: String) -> bool:
	return _file_filter.search(file_path) == null


func ignore_method(method_name: String) -> bool:
	return _method_filter.search(method_name) == null


func _to_string() -> String:
	return to_string_with_separator()


func to_string_with_separator(separator:=", ") -> String:
	var filters: Array[String] = []

	if _file_filter_pattern != ".*":
		filters.append("File filter: \"%s\"" % _file_filter_pattern)
	else:
		filters.append("No file filter")

	if _method_filter_pattern != ".*":
		filters.append("Method filter: \"%s\"" % _method_filter_pattern)
	else:
		filters.append("No method filter")

	return separator.join(filters)
