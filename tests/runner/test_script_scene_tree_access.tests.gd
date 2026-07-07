extends Node


func _init() -> void:
	name = "TestScriptNode"


func test_has_parent() -> TestCaseResult:
	var parent := get_parent()
	return TestCaseResult.new(parent != null, "Expected non null parent! Got %s" % parent)



func test_can_access_scene_tree() -> Array[TestCaseResult]:
	var results: Array[TestCaseResult] = []
	results.append(TestCaseResult.from_equals(true, is_inside_tree()))
	results.append(TestCaseResult.from_equals(true, get_tree() != null))
	return results
