"""Download and extract a Godot Windows executable from a release archive."""

import argparse
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path

URL_FORMAT = "https://github.com/godotengine/godot/releases/download/[VERSION]/Godot_v[VERSION]_win64.exe.zip"


def download_godot_executable(version: str, destination: Path) -> None:
	"""Download a Godot release zip and copy its executable to destination."""
	url = URL_FORMAT.replace("[VERSION]", version)
	destination.parent.mkdir(parents=True, exist_ok=True)

	with tempfile.TemporaryDirectory() as temporary_directory:
		zip_path = Path(temporary_directory) / "godot.zip"
		urllib.request.urlretrieve(url, zip_path)

		with zipfile.ZipFile(zip_path) as archive:
			executables = [
				name for name in archive.namelist()
				if name.lower().endswith(".exe")
			]

			if len(executables) == 0:
				raise RuntimeError(f"No executable found in Godot release archive: {url}")

			with archive.open(executables[0]) as source:
				with destination.open("wb") as target:
					shutil.copyfileobj(source, target)


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("version")
	parser.add_argument("destination")

	args = parser.parse_args()
	download_godot_executable(args.version, Path(args.destination))


if __name__ == "__main__":
	main()
