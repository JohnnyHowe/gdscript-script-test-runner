func helper_method():
	return true


func sample_test_generator() -> Dictionary[String, Callable]:
	return {
		"test_generated_b": func(): return true,
		"test_generated_a": func(): return true
	}


func test_regular():
	return true
