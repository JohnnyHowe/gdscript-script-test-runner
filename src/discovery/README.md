# Simplified Test Discovery

`discovery` is a smaller discovery pipeline that finds test files and test cases without creating runner callables or legacy discovery metadata.

The public entry point is `test_discovery.gd`. The command line entry point is `discover.gd`.

## Structure

```text
discovery/
  discover.gd
  search_criteria.gd
  test_discovery.gd
  data/
    test_suite.gd
    test_file.gd
    test_case.gd
  parsing/
    gdscript_method_line_index.gd
  reading/
    test_file_loader.gd
  scanning/
    test_file_finder.gd
```

- `search_criteria.gd` contains the file and method search settings needed by simplified discovery.
- `test_discovery.gd` coordinates scanning and reading, returning a `TestSuite`.
- `scanning/` finds candidate `GDScript` test files.
- `reading/` turns one script into a `TestFile` with `TestCase` entries.
- `parsing/` reads 1-based method declaration line numbers from source files.
- `data/` contains JSON-friendly discovery data objects with `to_dictionary()` methods.

## Command Line JSON

From the Godot project root:

```shell
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- results_file=res://discovered_tests.json
```

Useful filters:

```shell
godot --headless --quit -s addons/gdscript-script-test-runner/src/discovery/discover.gd -- test_file_pattern=combat test_name_pattern=^test_ results_file=res://discovered_tests.json
```

Use `hide_results=true` to write the file without printing the JSON to stdout.

The JSON output mirrors the simplified data objects:

```json
{
	"files": [
		{
			"file_path": "res://tests/example.tests.gd",
			"cases": [
				{
					"file_path": "res://tests/example.tests.gd",
					"method_name": "test_example",
					"line_number": 12
				}
			]
		}
	]
}
```

## GDScript Usage

```gdscript
const SearchCriteria := preload("res://addons/gdscript-script-test-runner/src/discovery/search_criteria.gd")
const TestDiscovery := preload("res://addons/gdscript-script-test-runner/src/discovery/test_discovery.gd")


func discover_tests():
	var search_criteria := SearchCriteria.new()
	var suite := TestDiscovery.new(search_criteria).discover()
	var json := JSON.stringify(suite.to_dictionary(), "\t")
	print(json)
```

For CLI-compatible criteria:

```gdscript
var args := UserArgumentParser.parse_cmdline_user_args()
var search_criteria = SearchCriteria.from_cli_args(args)
```

## Data Objects

- `TestSuite` contains `files: Array[TestFile]`.
- `TestFile` contains `file_path: StringName` and `cases: Array[TestCase]`.
- `TestCase` contains `file_path: StringName`, `method_name: StringName`, and `line_number: int`.
