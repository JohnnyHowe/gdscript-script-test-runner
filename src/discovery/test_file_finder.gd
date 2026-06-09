## Finds GDScript test files under the configured search root.
## Discovery uses direct directory traversal so newly created scripts are visible immediately.
const _Configuration := preload("../configuration.gd")

var _configuration: _Configuration


func _init(configuration: _Configuration) -> void:
	_configuration = configuration


func find() -> Array[GDScript]:
	var test_files: Array[GDScript] = []
	for file_path in _find_candidate_file_paths():
		if _configuration.filter.should_ignore_file(file_path):
			continue
		var test_file = load(file_path)
		if test_file is GDScript:
			test_files.append(test_file)

	test_files.sort_custom(func(a: GDScript, b: GDScript): return a.resource_path < b.resource_path)
	return test_files


func _find_candidate_file_paths() -> Array[String]:
	var file_paths: Array[String] = []
	_append_candidate_file_paths(_configuration.search_root, file_paths)
	file_paths.sort()
	return file_paths


func _append_candidate_file_paths(folder_path: String, file_paths: Array[String]) -> void:
	if _should_ignore_folder(folder_path):
		return

	var directory := DirAccess.open(folder_path)
	if directory == null:
		return

	directory.list_dir_begin()
	var file_name := directory.get_next()
	while file_name != "":
		var file_path := folder_path.path_join(file_name)
		if directory.current_is_dir():
			_append_candidate_file_paths(file_path, file_paths)
		elif file_path.ends_with(_configuration.test_file_name_postfix):
			file_paths.append(file_path)
		file_name = directory.get_next()


func _should_ignore_folder(folder_path: String) -> bool:
	for part in folder_path.trim_prefix("res://").split("/"):
		if part.begins_with("."):
			return true
	return false
