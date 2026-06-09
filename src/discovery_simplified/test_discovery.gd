## Public entry point for the test discovery namespace.
## Finds tests without running them and can adapt discovered data for the existing runner.
const _Configuration := preload("../configuration.gd")

const TestSuite := preload("./data/test_suite.gd")
const TestFileFinder := preload("./scanning/test_file_finder.gd")
const TestFileLoader := preload("./reading/test_file_loader.gd")

var _configuration: _Configuration
var _file_finder: TestFileFinder


func _init(configuration: _Configuration) -> void:
	_configuration = configuration
	_file_finder = TestFileFinder.new(configuration)


func discover() -> TestSuite:
	var suite := TestSuite.new()

	for script: GDScript in _file_finder.find():
		suite.files.append(TestFileLoader.new(script, _configuration).load())

	return suite
