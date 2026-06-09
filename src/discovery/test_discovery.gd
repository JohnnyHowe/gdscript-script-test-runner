## Public entry point for the test discovery namespace.
## Finds tests without running them and can adapt discovered data for the existing runner.
const _Configuration := preload("../configuration.gd")
const _TestDataObjects := preload("../test_data_objects/main.gd")

const DiscoveredTest := preload("./discovered_test.gd")
const DiscoveredTestScript := preload("./discovered_test_script.gd")
const DiscoveryJsonWriter := preload("./discovery_json_writer.gd")
const TestFileFinder := preload("./test_file_finder.gd")
const TestMethodDiscoverer := preload("./test_method_discoverer.gd")
const TestSourceLineFinder := preload("./test_source_line_finder.gd")

var _configuration: _Configuration
var _file_finder: TestFileFinder
var _method_discoverer: TestMethodDiscoverer


func _init(configuration: _Configuration) -> void:
	_configuration = configuration
	_file_finder = TestFileFinder.new(configuration)
	_method_discoverer = TestMethodDiscoverer.new(configuration)


func discover() -> Array[DiscoveredTestScript]:
	var test_scripts: Array[DiscoveredTestScript] = []
	for test_file in _file_finder.find():
		var tests := _method_discoverer.discover(test_file)
		test_scripts.append(DiscoveredTestScript.new(test_file, tests))
	return test_scripts


func discover_test_scripts() -> Array[_TestDataObjects.TestScript]:
	var test_scripts: Array[_TestDataObjects.TestScript] = []
	for discovered_test_script in discover():
		test_scripts.append(discovered_test_script.to_test_script())
	return test_scripts
