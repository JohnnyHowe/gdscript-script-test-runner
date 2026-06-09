import argparse
from pathlib import Path
import subprocess


def parse_args():
	parser = argparse.ArgumentParser(description="Discover Godot GDScript tests.")
	parser.add_argument(
		"--project-root",
		default=str(Path.cwd()),
		help="Path to the Godot project root (defaults to current working directory).",
	)
	parser.add_argument("--test-file-pattern", default=".*", help="Regex for test file paths.")
	parser.add_argument("--test-name-pattern", default=".*", help="Regex for test method names.")
	parser.add_argument(
		"--hide-results",
		default=False,
		action="store_true",
		help="Do not print the discovery JSON to stdout.",
	)
	parser.add_argument("--results-file", default=None, help="Write the discovery JSON to a file.")
	return parser.parse_args()


def _format_bool(value: bool) -> str:
	return "true" if value else "false"


def _quote_if_needed(value: str) -> str:
	if any(char.isspace() for char in value):
		escaped = value.replace('"', '\\"')
		return '"' + escaped + '"'
	return value


def discover_tests():
	args = parse_args()
	project_root = Path(args.project_root).resolve()
	script_path = (Path(__file__).parent / "discover_tests.gd").resolve()
	try:
		godot_script_path = script_path.relative_to(project_root)
	except ValueError:
		godot_script_path = script_path

	discover_tests_command = [
		"godot",
		"--path", str(project_root),
		"--headless",
		"--quit",
		"-s", str(godot_script_path),
	]

	user_args = [
		f"test_file_pattern={_quote_if_needed(args.test_file_pattern)}",
		f"test_name_pattern={_quote_if_needed(args.test_name_pattern)}",
		f"hide_results={_format_bool(args.hide_results)}",
	]
	if args.results_file is not None:
		user_args.append(f"results_file={_quote_if_needed(args.results_file)}")

	full_command = discover_tests_command + ["--"] + user_args
	result = subprocess.run(full_command)
	raise SystemExit(result.returncode)


if __name__ == "__main__":
	discover_tests()
