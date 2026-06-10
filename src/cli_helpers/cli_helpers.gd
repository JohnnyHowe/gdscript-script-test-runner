const WriteToFile := preload("./write_to_file.gd")
const TestSuite := preload("../data/tests/test_suite.gd")
const TestSuiteResult := preload("../data/results/test_suite_result.gd")


static func load_test_suite(file_path: StringName) -> TestSuite:
	var data = _load_as_json(file_path)

	if not data is Dictionary:
		push_error("Loading test suite from %s failed." % file_path)
		return null

	return TestSuite.from_dictionary(data)


static func load_test_suite_results(file_path: StringName) -> TestSuiteResult:
	var data = _load_as_json(file_path)

	if not data is Dictionary:
		push_error("Loading test suite from %s failed." % file_path)
		return null

	return TestSuiteResult.from_dictionary(data)



static func _load_as_json(file_path: StringName) -> Variant:
	if file_path.is_empty():
		push_error("Cannot read from empty file_path!")
		return null

	if not FileAccess.file_exists(file_path):
		push_error("Path %s does not exist!" % [file_path])
		return null

	var contents := FileAccess.get_file_as_string(file_path)

	var parser := JSON.new()
	var err := parser.parse(contents)

	if err != OK:
		push_error("Test suite (%s) json parse failed! error=\"%s\"" % [file_path, parser.get_error_message()])
		return null

	return parser.data



