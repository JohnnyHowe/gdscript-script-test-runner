# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0]

### Added
- Local VS Code extension support for discovering and running GDScript tests from the Test Explorer.
- Discovery CLI and JSON-friendly test metadata for tooling integrations.
- Support for running JSON test suites and writing JSON or Markdown results.

### Changed
- Renamed CLI args for clarity.
- Simplified discovery and result schemas around suites, files, and cases.

### Fixed
- Fixed passed-test hiding and VS Code extension discovery issues.

### Removed
- Removed legacy discovery, loader, logging, configuration, and test data code paths.

## [1.2.0]

### Added
- `stop_on_first_failed_test` CLI arg

## [1.1.0]

### Added
- Python `run_tests` wrapper
