#' Identify cell types from marker genes using AI models
#'
#' This function takes a list of marker genes and uses large language models 
#' (Claude or Gemini) to predict the most likely cell type(s) based on gene 
#' expression patterns. The function provides context-aware predictions 
#' considering tissue type and species.
#'
#' @param genes A character vector of gene symbols/names to analyze. Gene names 
#'   should follow standard nomenclature (e.g., HUGO symbols for human genes).
#' @param model A character string specifying the AI model to use. Default is 
#'   "claude-3-5-sonnet-20241022". Model options by LLM:
#'   \itemize{
#'     \item Claude: "claude-3-5-sonnet-20241022", "claude-3-opus-20240229", "claude-3-haiku-20240307"
#'     \item Gemini: "gemini-1.5-pro", "gemini-1.5-flash", "gemini-1.0-pro"
#'     \item ChatGPT: "gpt-4o", "gpt-4-turbo", "gpt-4", "gpt-3.5-turbo"
#'   }
#' @param tissue_context An optional character string specifying the tissue 
#'   context (e.g., "peripheral blood", "brain", "liver"). This helps improve 
#'   prediction accuracy by providing biological context.
#' @param species A character string specifying the species. Must be one of: 
#'   "human", "mouse", "rat", "zebrafish", "drosophila". Default is "human".
#' @param save_results A logical value indicating whether to save results to 
#'   an RDS file. Default is FALSE.
#' @param output_file An optional character string specifying the output file 
#'   path. If NULL and save_results is TRUE, a timestamped filename will be 
#'   generated automatically.
#' @param llm A character string specifying which language model service to use. 
#'   Must be one of "claude", "gemini", or "chatgpt". Default is "claude".
#'
#' @return A list containing:
#'   \item{genes_queried}{Character vector of genes that were analyzed}
#'   \item{model_used}{Character string of the AI model used}
#'   \item{llm_used}{Character string of the LLM service used}
#'   \item{tissue_context}{Character string of tissue context (if provided)}
#'   \item{species}{Character string of the species analyzed}
#'   \item{response}{Character string containing the AI model's response}
#'   \item{timestamp}{POSIXct timestamp of when the analysis was performed}
#'
#' @details
#' The function constructs a biological prompt asking the AI model to identify 
#' cell types based on the provided marker genes. The prompt requests:
#' \itemize{
#'   \item Most likely cell type(s) with confidence levels
#'   \item Key supporting genes from the input list
#'   \item Alternative possibilities
#'   \item Brief biological rationale
#' }
#'
#' The function requires the \code{ellmer} package for AI model communication 
#' and \code{glue} for prompt construction.
#'
#' @examples
#' \dontrun{
#' # Basic usage with T cell markers
#' markers <- c("CD3D", "CD3E", "CD8A", "CD8B", "GZMB", "PRF1")
#' result <- identify_celltype(markers)
#' 
#' # With tissue context
#' result <- identify_celltype(markers, tissue_context = "peripheral blood")
#' 
#' # Using Gemini instead of Claude
#' result <- identify_celltype(markers, llm = "gemini")
#' 
#' # Using ChatGPT
#' result <- identify_celltype(markers, llm = "chatgpt")
#' 
#' # Save results to file
#' result <- identify_celltype(markers, save_results = TRUE)
#' 
#' # Mouse genes
#' mouse_markers <- c("Cd3d", "Cd3e", "Cd8a", "Cd8b")
#' result <- identify_celltype(mouse_markers, species = "mouse")
#' 
#' # Using specific models
#' result <- identify_celltype(markers, llm = "claude", model = "claude-3-opus-20240229")
#' result <- identify_celltype(markers, llm = "gemini", model = "gemini-1.5-pro")
#' result <- identify_celltype(markers, llm = "chatgpt", model = "gpt-4o")
#' }
#'
#' @seealso
#' \code{\link[ellmer]{chat_claude}}, \code{\link[ellmer]{chat_gemini}}, \code{\link[ellmer]{chat_openai}}
#'
#' @importFrom ellmer chat_claude chat_gemini chat_openai
#' @importFrom glue glue
#' @export
identify_celltype <- function(genes,
                              model = "claude-3-5-sonnet-20241022",
                              tissue_context = NULL,
                              species = "human",
                              save_results = FALSE,
                              output_file = NULL,
                              llm = "claude") {

  # Validate inputs
  if(missing(genes)) stop("genes parameter is required")
  if(length(genes) == 0) stop("No genes provided")
  if(!is.character(genes)) stop("genes must be a character vector")
  
  # Clean gene names
  genes <- genes[!is.na(genes) & genes != ""]
  if(length(genes) == 0) stop("No valid genes after removing NA and empty values")
  
  # Validate model parameter
  if(!is.character(model) || length(model) != 1) {
    stop("model must be a single character string")
  }
  
  # Validate tissue_context
  if(!is.null(tissue_context) && (!is.character(tissue_context) || length(tissue_context) != 1)) {
    stop("tissue_context must be NULL or a single character string")
  }
  
  # Validate species
  valid_species <- c("human", "mouse", "rat", "zebrafish", "drosophila")
  if(!is.character(species) || length(species) != 1 || !species %in% valid_species) {
    stop("species must be one of: ", paste(valid_species, collapse = ", "))
  }
  
  # Validate save_results
  if(!is.logical(save_results) || length(save_results) != 1) {
    stop("save_results must be TRUE or FALSE")
  }
  
  # Validate output_file
  if(!is.null(output_file) && (!is.character(output_file) || length(output_file) != 1)) {
    stop("output_file must be NULL or a single character string")
  }
  
  # Validate llm parameter
  valid_llms <- c("claude", "gemini", "chatgpt")
  if(!is.character(llm) || length(llm) != 1 || !llm %in% valid_llms) {
    stop("llm must be one of: ", paste(valid_llms, collapse = ", "))
  }

  # Create context-aware prompt
  tissue_text <- if(!is.null(tissue_context)) paste("in", tissue_context, "tissue") else ""
  species_text <- paste("in", species)

  gene_list <- paste(genes, collapse = ", ")

  prompt <- glue::glue("
    Based on these marker genes: {gene_list}

    What cell type(s) do these genes most likely represent {species_text} {tissue_text}?

    Please provide:
    1. Most likely cell type(s) with confidence level
    2. Key supporting genes from the list
    3. Any alternative possibilities
    4. Brief biological rationale

    Format your response clearly and concisely.
  ")

  # Query the model with error handling
  tryCatch({
    if(llm == "claude"){
      chat <- chat_claude(model = model)
    } else if (llm == "gemini"){
      chat <- chat_gemini(model = model)
    } else if (llm == "chatgpt"){
      chat <- chat_openai(model = model)
    }
    
    response <- chat$chat(prompt)
  }, error = function(e) {
    stop("Error querying ", llm, " model '", model, "': ", e$message)
  })

  # Handle response format (elmer returns character vector, not list)
  response_text <- if(is.character(response)) response else as.character(response)

  # Parse and structure the response
  result <- list(
    genes_queried = genes,
    model_used = model,
    llm_used = llm,
    tissue_context = tissue_context,
    species = species,
    response = response_text,
    timestamp = Sys.time()
  )

  # Save results if requested
  if(save_results) {
    filename <- output_file %||% paste0("celltype_identification_",
                                        format(Sys.time(), "%Y%m%d_%H%M%S"),
                                        ".rds")
    
    # Validate output directory exists
    output_dir <- dirname(filename)
    if(!dir.exists(output_dir)) {
      stop("Output directory does not exist: ", output_dir)
    }
    
    tryCatch({
      saveRDS(result, filename)
      message("Results saved to: ", filename)
    }, error = function(e) {
      stop("Error saving results to ", filename, ": ", e$message)
    })
  }

  # Print formatted output
  cat("=== CELL TYPE IDENTIFICATION ===\n")
  cat("Genes analyzed:", length(genes), "\n")
  cat("Model:", model, "\n")
  cat("LLM:", llm, "\n")
  if(!is.null(tissue_context)) cat("Tissue context:", tissue_context, "\n")
  cat("Species:", species, "\n\n")
  cat("RESPONSE:\n")
  cat(response_text, "\n")

  invisible(result)
}
