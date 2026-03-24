var file_filter_pattern: String:
	get: return _file_filter_pattern

var method_filter_pattern: String:
	get: return _method_filter_pattern

var ignored_patterns: Array[String]:
	get: return _ignored_patterns

var _file_filter_pattern: String
var _method_filter_pattern: String
var _file_filter = RegEx.new()
var _method_filter = RegEx.new()
var _ignored_patterns: Array[String]
var _ignored_regex: RegEx


func _init(
	file_filter_pattern := ".*",
	method_filter_pattern := ".*",
	ignored_patterns_value: Array[String] = []
) -> void:
	_file_filter_pattern = file_filter_pattern
	_method_filter_pattern = method_filter_pattern
	_ignored_patterns = ignored_patterns_value
	_ignored_regex = _compile_ignored_regex(_ignored_patterns)
	_file_filter.compile(_file_filter_pattern)
	_method_filter.compile(_method_filter_pattern)


func _compile_ignored_regex(patterns: Array[String]) -> RegEx:
	if patterns.is_empty():
		return null
	var regex := RegEx.new()
	var joined := "(" + ")|(".join(patterns) + ")"
	if regex.compile(joined) != OK:
		return null
	return regex


func should_ignore_file(file_path: String) -> bool:
	if _ignored_regex != null and _ignored_regex.search(file_path) != null:
		return true
	return _file_filter.search(file_path) == null


func should_ignore_method(method_name: String) -> bool:
	return _method_filter.search(method_name) == null


func _to_string() -> String:
	return "TestFilter(files=%s, methods=%s, ignore=%s)" % [
		_file_filter_pattern,
		_method_filter_pattern,
		_ignored_patterns
	]


static func get_path_ignore_pattern(folder_path: String) -> String:
	return "^%s(/|$)" % _escape_regex(folder_path)


static func _escape_regex(value: String) -> String:
	var escaped := ""
	for character in value:
		match character:
			".", "^", "$", "*", "+", "?", "(", ")", "[", "]", "{", "}", "|", "\\":
				escaped += "\\" + character
			_:
				escaped += character
	return escaped
