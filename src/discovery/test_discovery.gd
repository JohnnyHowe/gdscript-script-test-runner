## Public entry point for the test discovery namespace.
## Finds tests without running them and can adapt discovered data for the existing runner.
const SearchCriteria := preload("./search_criteria.gd")
const TestSuite := preload("./data/test_suite.gd")
const TestFileFinder := preload("./scanning/test_file_finder.gd")
const TestFileLoader := preload("./reading/test_file_loader.gd")

var _search_criteria: SearchCriteria
var _file_finder: TestFileFinder


func _init(search_criteria: SearchCriteria) -> void:
	_search_criteria = search_criteria
	_file_finder = TestFileFinder.new(search_criteria)


func discover() -> TestSuite:
	var suite := TestSuite.new()

	for script: GDScript in _file_finder.find():
		suite.files.append(TestFileLoader.new(script, _search_criteria).load())

	return suite
