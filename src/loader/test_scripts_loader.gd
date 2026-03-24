const _Configuration := preload("../configuration.gd")
const _TestDataObjects := preload("../test_data_objects/main.gd")
const _TestScriptLoader := preload("./test_script_loader.gd")

var _configuration: _Configuration


func _init(configuration: _Configuration) -> void:
	_configuration = configuration


func load() -> Array[_TestDataObjects.TestScript]:
	var test_scripts: Array[_TestDataObjects.TestScript] = []
	var script_loader := _TestScriptLoader.new(_configuration)
	for test_file in _find_test_files().values():
		if not _configuration.filter.should_ignore_file(test_file.resource_path):
			test_scripts.append(script_loader.load(test_file))

	return test_scripts


func _find_test_files() -> Dictionary:
	return BetterResourceLoader.get_all_resources_in_folder_recursive(
		_configuration.search_root,
		_is_test_script
	)


func _is_test_script(resource: Resource) -> bool:
	if not resource is GDScript:
		return false
	return resource.resource_path.ends_with(_configuration.test_file_name_postfix)
