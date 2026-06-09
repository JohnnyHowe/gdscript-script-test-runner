const TestFile := preload("./test_file.gd")
const TestCase := TestFile.TestCase


var files: Array[TestFile] = []


static func from_dictionary(dictionary: Dictionary):
	var test_suite := new()

	for test_file_dictionary: Dictionary in dictionary["files"]:
		test_suite.files.append(TestFile.from_dictionary(test_file_dictionary))

	return test_suite


func to_dictionary() -> Dictionary:
	return {
		"files": files.map(func(file: TestFile): return file.to_dictionary())
	}
