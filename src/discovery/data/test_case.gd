var file_path: StringName
var method_name: StringName
var line_number: int


func to_dictionary() -> Dictionary:
	return {
		"file_path": String(file_path),
		"method_name": String(method_name),
		"line_number": line_number
	}
