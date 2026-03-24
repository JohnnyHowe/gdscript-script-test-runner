var print_logs: bool = true

var _file_path: String
var _log_to_file: bool = false


func _init() -> void:
	pass


func log_to_file(file_path: String) -> void:
	_file_path = file_path
	_log_to_file = true


func log(text: String = "") -> void:
	if print_logs:
		print(text)
	if _log_to_file:
		_append_line(text)


func _append_line(text: String) -> void:
	var file = FileAccess.open(_file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
	else:
		file = FileAccess.open(_file_path, FileAccess.WRITE)
	file.store_line(text)
	file.close()
