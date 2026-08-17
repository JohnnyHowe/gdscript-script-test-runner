## Captures Godot file-log output produced while a test runs.

var _enabled := false
var _log_path := ""
var _start_position := 0


func _init() -> void:
	var file_logging_enabled := ProjectSettings.get_setting("debug/file_logging/enable_file_logging", true)
	if not file_logging_enabled:
		return

	var configured_path := String(ProjectSettings.get_setting("debug/file_logging/log_path", "user://logs/godot.log"))
	_log_path = ProjectSettings.globalize_path(configured_path)
	_enabled = FileAccess.file_exists(_log_path)
	if _enabled:
		_start_position = _get_log_end_position()


## Marks the current end of the Godot log as the start of a test's output.
func begin_test() -> void:
	if not _enabled:
		return

	_start_position = _get_log_end_position()


## Returns log output written since [method begin_test] was called.
func end_test() -> String:
	if not _enabled:
		return ""

	var length := _get_log_end_position()
	if _start_position >= length:
		return ""

	var file := FileAccess.open(_log_path, FileAccess.READ)
	if file == null:
		_enabled = false
		return ""

	file.seek(_start_position)
	var logs := file.get_buffer(length - _start_position).get_string_from_utf8()
	_start_position = length
	return logs


## Returns the byte position where written log content ends, excluding trailing null bytes.
func _get_log_end_position() -> int:
	var file := FileAccess.open(_log_path, FileAccess.READ)
	if file == null:
		_enabled = false
		return 0

	var contents := file.get_buffer(file.get_length())
	for i in contents.size():
		if contents[i] == 0:
			return i

	return contents.size()
