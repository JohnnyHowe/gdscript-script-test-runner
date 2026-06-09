class_name TestCaseResult

const TestCase := preload("../tests/test_case.gd")
const _NO_REASON_GIVEN := "No reason given"

var passed: bool
var message: String
var test_case: TestCase


@warning_ignore("SHADOWED_VARIABLE")
func _init(passed: bool, failed_message: String = _NO_REASON_GIVEN) -> void:
	self.passed = passed
	self.message = failed_message
	if failed_message.begins_with("\n"):
		print(failed_message)


func get_display_string() -> String:
	var passed_state_emoji := "✅" if passed else "❌"
	var header := "%s %s" % [passed_state_emoji, test_case.method_name]

	if passed:
		return header

	var separator = "\nFailure reasons:\n" if message.contains("\n") else ": "
	return "%s%s%s" % [header, separator, message]


func _to_string() -> String:
	return "Test Result: %s, %s" % [passed, message]

# =================================================================================================
# region Extra Constructors
# =================================================================================================

static func from_equals(expected, actual, failed_message: String = _NO_REASON_GIVEN, equals_override := EqualsOverride.equals_operator) -> TestCaseResult:
	var correct_type := typeof(expected) == typeof(actual)

	if not correct_type:
		var comparision = "\n\tExpected %s: %s\n\tGot %s: %s" % [type_string(typeof(expected)), expected, type_string(typeof(actual)), actual]
		var message = (failed_message + ". " if failed_message != "" else "") + comparision
		return TestCaseResult.new(false, message)

	return from_equivalent(expected, actual, failed_message, equals_override)


static func from_equivalent(expected, actual, failed_message: String = _NO_REASON_GIVEN, equals_override := EqualsOverride.equals_operator) -> TestCaseResult:
	if equals_override.call(expected, actual):
		return TestCaseResult.new(true)

	var comparision = "\n\tExpected: %s\n\tGot:      %s" % [expected, actual]
	var final_message = (failed_message + ". " if failed_message != "" else "") + comparision
	return TestCaseResult.new(false, final_message)


static func not_implemented() -> TestCaseResult:
	return TestCaseResult.fail("Test not implemented!")


static func fail(fail_message: String = _NO_REASON_GIVEN) -> TestCaseResult:
	return TestCaseResult.new(false, fail_message)


static func succeed() -> TestCaseResult:
	return TestCaseResult.new(true)


static func contains_same_items(expected: Array, real: Array, equals_override := EqualsOverride.equals_operator_type_safe) -> Array[TestCaseResult]:
	var test_results: Array[TestCaseResult] = []

	test_results.append(TestCaseResult.new(expected.size() == real.size(), "Expected array of size %s, got %s" % [expected.size(), real.size()]))

	for expected_item in ArrayUtility.ArraySetOperations.difference(expected, real, equals_override):
		test_results.append(TestCaseResult.fail("Expected to find %s" % _get_item_str(expected_item)))
	for real_item in ArrayUtility.ArraySetOperations.difference(real, expected, equals_override):
		test_results.append(TestCaseResult.fail("Didn't expect to find %s" % _get_item_str(real_item)))

	return test_results


static func exists(obj: Variant, error_message := "Object reference invalid!") -> TestCaseResult:
	return TestCaseResult.new(obj != null and is_instance_valid(obj), error_message)

# =================================================================================================
# region ???
# =================================================================================================

static func _get_item_str(item: Variant) -> String:
	if item is String:
		return "\"%s\"" % item
	return str(item)
