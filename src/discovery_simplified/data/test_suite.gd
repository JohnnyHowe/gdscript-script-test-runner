const TestFile := preload("./test_file.gd")
const TestCase := TestFile.TestCase


var files: Array[TestFile] = []


func to_dictionary() -> Dictionary:
	return {
		"files": files.map(func(file: TestFile): return file.to_dictionary())
	}
