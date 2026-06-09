## Public entry point for the test discovery namespace.
## Finds tests without running them and can adapt discovered data for the existing runner.
const _Configuration := preload("../configuration.gd")
const _TestDataObjects := preload("../test_data_objects/main.gd")

const DiscoveredTest := preload("./data/discovered_test.gd")
const DiscoveredTestScript := preload("./data/discovered_test_script.gd")
const DiscoveryJson := preload("./output/discovery_json.gd")
const TestFileFinder := preload("./scanning/test_file_finder.gd")
const TestScriptDiscoverer := preload("./loading/test_script_discoverer.gd")
const GDScriptMethodLineIndex := preload("./parsing/gdscript_method_line_index.gd")

var _configuration: _Configuration
var _file_finder: TestFileFinder
var _script_discoverer: TestScriptDiscoverer


func _init(configuration: _Configuration) -> void:
	_configuration = configuration
	_file_finder = TestFileFinder.new(configuration)
	_script_discoverer = TestScriptDiscoverer.new(configuration)


func discover() -> Array[DiscoveredTestScript]:
	var test_scripts: Array[DiscoveredTestScript] = []
	for test_file in _file_finder.find():
		var tests := _script_discoverer.discover(test_file)
		test_scripts.append(DiscoveredTestScript.new(test_file, tests))
	return test_scripts


func discover_test_scripts() -> Array[_TestDataObjects.TestScript]:
	var test_scripts: Array[_TestDataObjects.TestScript] = []
	for discovered_test_script in discover():
		test_scripts.append(discovered_test_script.to_test_script())
	return test_scripts
