## Indexes 1-based declaration line numbers for methods in a GDScript source file.
## Used so discovery metadata can point editors and CLI tools back to source.
const UNKNOWN_LINE := -1


static func get_method_lines(file_path: String) -> Dictionary[String, int]:
	var method_lines: Dictionary[String, int] = {}
	if not FileAccess.file_exists(file_path):
		return method_lines

	var lines := FileAccess.get_file_as_string(file_path).split("\n")
	for index in lines.size():
		var method_name := _get_method_name(lines[index])
		if method_name == "":
			continue
		method_lines[method_name] = index + 1

	return method_lines


static func get_method_line(file_path: String, method_name: String) -> int:
	return get_method_lines(file_path).get(method_name, UNKNOWN_LINE)


static func _get_method_name(line: String) -> String:
	var stripped := line.strip_edges()
	if stripped.begins_with("static func "):
		stripped = stripped.trim_prefix("static ")
	elif not stripped.begins_with("func "):
		return ""

	var declaration := stripped.trim_prefix("func ")
	var name_end := declaration.find("(")
	if name_end < 0:
		return ""

	return declaration.substr(0, name_end).strip_edges()
