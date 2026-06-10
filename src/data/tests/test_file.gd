const TestCase := preload("./test_case.gd")


var file_path: StringName
var cases: Array[TestCase] = []


static func from_dictionary(dictionary: Dictionary):
	var test_file := new()
	test_file.file_path = StringName(dictionary["file_path"])

	for test_case_dictionary: Dictionary in dictionary["cases"]:
		test_file.cases.append(TestCase.from_dictionary(test_case_dictionary))

	return test_file


func to_dictionary() -> Dictionary:
	return {
		"file_path": String(file_path),
		"cases": cases.map(func(test_case: TestCase): return test_case.to_dictionary())
	}
