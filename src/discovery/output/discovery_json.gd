## Converts discovered test data into JSON-safe dictionaries and strings.
## Runtime-only values like Callables, script resources, and instances are omitted.
const DiscoveredTestScript := preload("../data/discovered_test_script.gd")


static func to_json(test_scripts: Array) -> String:
	return JSON.stringify(to_dictionary(test_scripts), "\t")


static func to_dictionary(test_scripts: Array) -> Dictionary:
	var script_metadata: Array[Dictionary] = []
	var test_count := 0
	for test_script in test_scripts:
		script_metadata.append(test_script.to_metadata())
		test_count += test_script.tests.size()

	return {
		"test_scripts_found": test_scripts.size(),
		"tests_found": test_count,
		"test_scripts": script_metadata
	}


static func write(path: String, test_scripts: Array) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(to_json(test_scripts))
	file.close()
