import argparse
from pathlib import Path
import subprocess


def parse_args():
	parser = argparse.ArgumentParser(description="Run Godot GDScript tests.")
	parser.add_argument(
		"--project-root",
		default=str(Path.cwd()),
		help="Path to the Godot project root (defaults to current working directory).",
	)
	parser.add_argument("--file-filter", default=".*", help="Regex for test file paths.")
	parser.add_argument("--method-filter", default=".*", help="Regex for test method names.")
	parser.add_argument(
		"--hide-passed",
		default=False,
		action="store_true",
		help="Hide passed tests in the output.",
	)
	parser.add_argument("--file-output", default=None, help="Write the log to a file.")
	return parser.parse_args()


def _format_bool(value: bool) -> str:
	return "true" if value else "false"


def _quote_if_needed(value: str) -> str:
	if any(char.isspace() for char in value):
		escaped = value.replace('"', '\\"')
		return '"' + escaped + '"'
	return value


def run_tests():
	this_folder_path = Path(__file__).parent

	args = parse_args()
	project_root = Path(args.project_root)

	run_tests_command = [
		"godot",
		"--path", str(project_root),
		"--headless",
		"--quit",
		"-s", str(this_folder_path / "run_tests.gd"),
	]

	user_args = [
		f"file_filter={_quote_if_needed(args.file_filter)}",
		f"method_filter={_quote_if_needed(args.method_filter)}",
		f"hide_passed={_format_bool(args.hide_passed)}",
	]
	if args.file_output is not None:
		user_args.append(f"file_output={_quote_if_needed(args.file_output)}")

	full_command = run_tests_command + ["--"] + user_args
	result = subprocess.run(full_command)
	raise SystemExit(result.returncode)


if __name__ == "__main__":
	run_tests()
