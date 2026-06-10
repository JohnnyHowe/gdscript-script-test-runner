# TODO

## GDScript runner

- [ ] Implement `fail_fast` in `run_tests.gd` / runner flow. It is documented and passed through by the Python wrapper, but the runner currently executes the full selected suite.
- [ ] Decide whether `hide_passed_tests` should still affect machine-readable JSON. It is documented, but the current VS Code path wants complete JSON and only uses `hide_results=true`.
- [ ] Convert script load errors and test runtime errors into structured failed test results when possible, so the VS Code extension can show per-test diagnostics instead of only process-level failures.
- [ ] Revisit documented test generators (`<name>_test_generator`) and confirm whether simplified discovery/run should support them or whether the README should be narrowed.
- [ ] Update README
- [ ] Update workflows (DwarfHold)
- [ ] Add template workflows

## VS Code extension

- [ ] Add a configurable Godot executable path instead of assuming `godot` is on `PATH`.
- [ ] Add an output channel for Godot stdout/stderr and extension diagnostics.
- [ ] Add durations to run results and pass them through to VS Code's Test API.
- [ ] Refresh discovery automatically when relevant `.gd` test files are saved, created, deleted, or renamed.
- [ ] Improve diagnostics when discovery succeeds with malformed entries, rather than only skipping invalid JSON items.
- [ ] Improve cancellation reporting after killing the Godot process.
