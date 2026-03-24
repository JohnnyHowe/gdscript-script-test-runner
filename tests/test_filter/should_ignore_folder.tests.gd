const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")


func test_get_path_ignore_pattern_matches_folder_paths() -> Array[ScriptTestResult]:
	var pattern := _TestFilter.get_path_ignore_pattern("res://.godot")
	var regex := RegEx.new()
	regex.compile(pattern)
	var results: Array[ScriptTestResult] = []
	results.append(ScriptTestResult.from_equals(true, regex.search("res://.godot") != null))
	results.append(ScriptTestResult.from_equals(true, regex.search("res://.godot/cache/file") != null))
	results.append(ScriptTestResult.from_equals(false, regex.search("res://.godot_cache") != null))
	return results
