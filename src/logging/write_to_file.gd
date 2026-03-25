
static func write(path: String, contents: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(contents)
	file.close()
