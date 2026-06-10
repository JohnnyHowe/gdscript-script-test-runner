var file_path: StringName
var method_name: StringName
var line_number: int


static func from_dictionary(dictionary: Dictionary):
	var test_case := new()
	test_case.file_path = StringName(dictionary["file_path"])
	test_case.method_name = StringName(dictionary["method_name"])
	test_case.line_number = dictionary["line_number"]
	return test_case


func to_dictionary() -> Dictionary:
	return {
		"id": get_id(),
		"file_path": String(file_path),
		"method_name": String(method_name),
		"line_number": line_number
	}


func get_id() -> StringName:
	return "%s::%s" % [file_path, method_name]
