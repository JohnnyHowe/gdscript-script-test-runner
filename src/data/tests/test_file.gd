const TestCase := preload("./test_case.gd")


var file_path: StringName
var cases: Array[TestCase] = []


func to_dictionary() -> Dictionary:
	return {
		"file_path": String(file_path),
		"cases": cases.map(func(test_case: TestCase): return test_case.to_dictionary())
	}
