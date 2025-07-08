test_that("set_api_key validates inputs correctly", {
  # Test missing service
  expect_error(set_api_key(api_key = "test"), "service parameter is required")
  
  # Test missing api_key
  expect_error(set_api_key("claude"), "api_key parameter is required")
  
  # Test invalid service type
  expect_error(set_api_key(123, "test"), "service must be a single character string")
  
  # Test invalid api_key type
  expect_error(set_api_key("claude", 123), "api_key must be a single character string")
  
  # Test invalid service value
  expect_error(set_api_key("invalid", "test"), "service must be one of")
  
  # Test empty api_key
  expect_error(set_api_key("claude", ""), "api_key cannot be empty")
  expect_error(set_api_key("claude", "   "), "api_key cannot be empty")
})

test_that("set_api_key sets environment variables correctly", {
  # Test Claude
  result <- set_api_key("claude", "test-claude-key")
  expect_true(result)
  expect_equal(Sys.getenv("ANTHROPIC_API_KEY"), "test-claude-key")
  
  # Test Gemini
  result <- set_api_key("gemini", "test-gemini-key")
  expect_true(result)
  expect_equal(Sys.getenv("GEMINI_API_KEY"), "test-gemini-key")
  
  # Test ChatGPT
  result <- set_api_key("chatgpt", "test-openai-key")
  expect_true(result)
  expect_equal(Sys.getenv("OPENAI_API_KEY"), "test-openai-key")
})

test_that("set_api_key handles whitespace in api_key", {
  # Should trim whitespace and set the key
  result <- set_api_key("claude", "  test-key-with-spaces  ")
  expect_true(result)
  expect_equal(Sys.getenv("ANTHROPIC_API_KEY"), "  test-key-with-spaces  ")
})

# Clean up environment variables after tests
teardown({
  Sys.unsetenv("ANTHROPIC_API_KEY")
  Sys.unsetenv("GEMINI_API_KEY")
  Sys.unsetenv("OPENAI_API_KEY")
})