class_name ScriptTestResult

const no_reason_given := "No reason given"

var passed: bool
var message: String
var test: ScriptTest


@warning_ignore("SHADOWED_VARIABLE")
func _init(passed: bool, failed_message: String = no_reason_given) -> void:
	self.passed = passed
	self.message = failed_message
	if failed_message.begins_with("\n"):
		print(failed_message)


func get_display_string() -> String:
	var passed_state_emoji := "✅" if passed else "❌"
	var header := "%s %s" % [passed_state_emoji, test.name]

	if passed:
		return header

	var separator = "\nFailure reasons:\n" if message.contains("\n") else ": "
	return "%s%s%s" % [header, separator, message]


func _to_string() -> String:
	return "Test Result: %s, %s" % [passed, message]

# =================================================================================================
# region Extra Constructors
# =================================================================================================

static func from_equals(expected, actual, failed_message: String = no_reason_given, equals_override := EqualsOverride.equals_operator) -> ScriptTestResult:
	var correct_type := typeof(expected) == typeof(actual)

	if correct_type and equals_override.call(expected, actual):
		return ScriptTestResult.new(true)

	var comparision := ""
	if not correct_type:
		comparision = "\n\tExpected %s: %s\n\tGot %s: %s" % [type_string(typeof(expected)), expected, type_string(typeof(actual)), actual]
	else:
		comparision = "\n\tExpected: %s\n\tGot:      %s" % [expected, actual]

	var final_message = (failed_message + ". " if failed_message != "" else "") + comparision
	return ScriptTestResult.new(false, final_message)


static func not_implemented() -> ScriptTestResult:
	return ScriptTestResult.fail("Test not implemented!")


static func fail(fail_message: String = no_reason_given) -> ScriptTestResult:
	return ScriptTestResult.new(false, fail_message)


static func succeed() -> ScriptTestResult:
	return ScriptTestResult.new(true)


static func contains_same_items(expected: Array, real: Array, equals_override := EqualsOverride.equals_operator_type_safe) -> Array[ScriptTestResult]:
	var test_results: Array[ScriptTestResult] = []

	test_results.append(ScriptTestResult.new(expected.size() == real.size(), "Expected array of size %s, got %s" % [expected.size(), real.size()]))

	for expected_item in ArrayUtility.difference(expected, real, equals_override):
		test_results.append(ScriptTestResult.fail("Expected to find %s" % _get_item_str(expected_item)))
	for real_item in ArrayUtility.difference(real, expected, equals_override):
		test_results.append(ScriptTestResult.fail("Didn't expect to find %s" % _get_item_str(real_item)))

	return test_results


static func exists(obj: Variant, error_message:="Object reference invalid!") -> ScriptTestResult:
	return ScriptTestResult.new(obj != null and is_instance_valid(obj), error_message)

# =================================================================================================
# region ???
# =================================================================================================

static func _get_item_str(item: Variant) -> String:
	if item is String:
		return "\"%s\"" % item
	return str(item)
