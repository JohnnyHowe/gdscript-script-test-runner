const TestFile := preload("./test_file.gd")
const TestCase := TestFile.TestCase


var files: Array[TestFile] = []


static func from_json_string(json_string: String):
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		return null

	return from_json(json)


static func from_json_file(file_path: StringName):
	return from_json_string(FileAccess.get_file_as_string(String(file_path)))


static func from_json(json: JSON):
	return from_dictionary(json.data)


static func from_dictionary(dictionary: Dictionary):
	var test_suite := new()

	for test_file_dictionary: Dictionary in dictionary["files"]:
		test_suite.files.append(TestFile.from_dictionary(test_file_dictionary))

	return test_suite


func to_dictionary() -> Dictionary:
	return {
		"files": files.map(func(file: TestFile): return file.to_dictionary())
	}
