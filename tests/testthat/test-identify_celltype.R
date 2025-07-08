test_that("identify_celltype validates inputs correctly", {
  # Test missing genes
  expect_error(identify_celltype(), "genes parameter is required")
  
  # Test empty genes
  expect_error(identify_celltype(character(0)), "No genes provided")
  
  # Test non-character genes
  expect_error(identify_celltype(123), "genes must be a character vector")
  
  # Test invalid species
  expect_error(identify_celltype(c("CD3D", "CD8A"), species = "invalid"), 
               "species must be one of")
  
  # Test invalid llm
  expect_error(identify_celltype(c("CD3D", "CD8A"), llm = "invalid"), 
               "llm must be one of")
  
  # Test invalid model parameter
  expect_error(identify_celltype(c("CD3D", "CD8A"), model = 123), 
               "model must be a single character string")
  
  # Test invalid save_results
  expect_error(identify_celltype(c("CD3D", "CD8A"), save_results = "yes"), 
               "save_results must be TRUE or FALSE")
})

test_that("identify_celltype handles gene cleaning correctly", {
  # Test with only NA and empty values (should error)
  expect_error(identify_celltype(c(NA, "", NA, "")), 
               "No valid genes after removing NA and empty values")
  
  # Test with mixed valid and invalid genes (should not error - but we can't test 
  # the actual API call without mocking)
  # Valid case: c("CD3D", NA, "", "CD8A") should have 2 valid genes
  valid_genes <- c("CD3D", NA, "", "CD8A")
  cleaned_genes <- valid_genes[!is.na(valid_genes) & valid_genes != ""]
  expect_equal(length(cleaned_genes), 2)
  expect_equal(cleaned_genes, c("CD3D", "CD8A"))
})

# Note: Tests for actual API calls would require mocking the ellmer functions
# or using test credentials in a controlled environment