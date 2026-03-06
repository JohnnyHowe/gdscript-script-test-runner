This doc outlines conventions for making tests.
These are not hard rules, but highly recommended.

# Folder
Put test files in `tests/` subfolder.
- Next to files being tested
- or if using `scripts/` or `src/` folder for scripts, put `tests/` next to that folder.

# Files
Split tests for different methods up into different test files when appropriate.

# Black Box
Tests should focus on black box functionality - functionality clients see.
If you are including white box testing, make that clear either with file or folder names.
