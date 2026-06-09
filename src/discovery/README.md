# Test Discovery

`test_discovery.gd` is the public entry point for the discovery namespace.

Discovery finds test scripts and test methods without running them. The regular test runner uses it, and it can also be called directly to produce JSON metadata.

## Structure

```text
discovery/
  test_discovery.gd
  data/
    discovered_test.gd
    discovered_test_script.gd
  loading/
    test_script_discoverer.gd
  output/
    discovery_json.gd
  parsing/
    gdscript_method_line_index.gd
  scanning/
    test_file_finder.gd
```

- `test_discovery.gd` is the public facade and namespace entry point.
- `data/` contains discovery data objects.
- `scanning/` finds candidate test files.
- `loading/` turns one script into discovered tests.
- `parsing/` reads source metadata that Godot reflection does not provide.
- `output/` formats discovery data for external tools.

## Command Line JSON

From the Godot project root:

```shell
godot --headless --quit -s addons/gdscript-script-test-runner/src/discover_tests.gd -- results_file=res://discovered_tests.json
```

Or with the Python wrapper:

```shell
python addons/gdscript-script-test-runner/src/discover_tests.py --results-file res://discovered_tests.json
```

Useful filters:

```shell
python addons/gdscript-script-test-runner/src/discover_tests.py --test-file-pattern "combat" --test-name-pattern "^test_"
```

The JSON output contains only metadata, not callables or script instances:

```json
{
	"test_scripts_found": 1,
	"tests_found": 2,
	"test_scripts": [
		{
			"file_path": "res://tests/example.tests.gd",
			"tests": [
				{
					"file_path": "res://tests/example.tests.gd",
					"name": "test_example",
					"source_method": "test_example",
					"line": 12,
					"kind": "regular"
				}
			]
		}
	]
}
```

## GDScript Usage

```gdscript
const _Configuration := preload("res://addons/gdscript-script-test-runner/src/configuration.gd")
const _TestDiscovery := preload("res://addons/gdscript-script-test-runner/src/discovery/test_discovery.gd")
const _TestFilter := preload("res://addons/gdscript-script-test-runner/src/test_filter.gd")


func discover_tests():
	var filter := _TestFilter.new(".*", ".*", [] as Array[String])
	var configuration := _Configuration.new(
		"res://",
		filter,
		".tests.gd",
		"test_",
		"_test_generator",
		false
	)

	var discovery := _TestDiscovery.new(configuration)
	var discovered_test_scripts := discovery.discover()
	var json := _TestDiscovery.DiscoveryJson.to_json(discovered_test_scripts)
	print(json)
```

For runner-compatible objects:

```gdscript
var executable_test_scripts := _TestDiscovery.new(configuration).discover_test_scripts()
```

## Discovered Data

- `DiscoveredTestScript` represents one test script and its discovered tests.
- `DiscoveredTest` represents one regular or generated test, including the 1-based line where the source method is declared.
- `DiscoveryJson` converts discovered data into JSON-safe dictionaries or strings.
