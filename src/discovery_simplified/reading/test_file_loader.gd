const SearchCriteria := preload("../search_criteria.gd")
const TestSuite := preload("../data/test_suite.gd")
const TestFile := TestSuite.TestFile
const TestCase := TestSuite.TestCase
const GDScriptMethodLineIndex := preload("../parsing/gdscript_method_line_index.gd")

var _search_criteria: SearchCriteria
var _script: GDScript
var _file_path: String
var _method_lines: Dictionary[String, int]


func _init(script: GDScript, search_criteria: SearchCriteria) -> void:
	_script = script
	_search_criteria = search_criteria
	_file_path = _script.resource_path
	_method_lines = GDScriptMethodLineIndex.get_method_lines(_file_path)


func load() -> TestFile:
	var file := TestFile.new()
	file.file_path = StringName(_file_path)

	var script_instance := _script.new()
	var methods: Array[Dictionary] = script_instance.get_method_list()
	methods.sort_custom(func(a: Dictionary, b: Dictionary): return a["name"] < b["name"])

	for method: Dictionary in methods:
		var test_case := _load_case_from_method(method)
		if test_case != null:
			file.cases.append(test_case)

	return file


func _load_case_from_method(method: Dictionary) -> TestCase:
	var method_name: String = method["name"]
	if _search_criteria.filter.should_ignore_method(method_name):
		return null
	if not method_name.begins_with(_search_criteria.test_function_name_prefix):
		return null

	return _load_case(
		_file_path,
		method_name,
		_method_lines.get(method_name, GDScriptMethodLineIndex.UNKNOWN_LINE)
	)


func _load_case(file_path: String, method_name: String, line_number: int) -> TestCase:
	var test_case := TestCase.new()
	test_case.file_path = StringName(file_path)
	test_case.method_name = StringName(method_name)
	test_case.line_number = line_number
	return test_case
