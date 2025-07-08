#' Set API key for AI services
#'
#' This function sets the API key for the specified AI service (Claude, Gemini, or ChatGPT).
#' The key will be stored in the current R session and used for subsequent API calls.
#'
#' @param service A character string specifying the AI service. Must be one of:
#'   "claude", "gemini", or "chatgpt".
#' @param api_key A character string containing the API key for the specified service.
#'
#' @details
#' API keys are stored as environment variables for the current R session:
#' \itemize{
#'   \item Claude: Sets ANTHROPIC_API_KEY environment variable
#'   \item Gemini: Sets GEMINI_API_KEY environment variable  
#'   \item ChatGPT: Sets OPENAI_API_KEY environment variable
#' }
#'
#' For security, avoid hardcoding API keys in scripts. Consider using:
#' \itemize{
#'   \item .Renviron file in your home directory
#'   \item Environment variables set in your shell
#'   \item R's keyring package for secure credential storage
#' }
#'
#' @return Invisibly returns TRUE if the key was set successfully.
#'
#' @examples
#' \dontrun{
#' # Set Claude API key
#' set_api_key("claude", "your-anthropic-api-key-here")
#' 
#' # Set Gemini API key
#' set_api_key("gemini", "your-gemini-api-key-here")
#' 
#' # Set ChatGPT API key
#' set_api_key("chatgpt", "your-openai-api-key-here")
#' 
#' # After setting keys, you can use identify_celltype
#' markers <- c("CD3D", "CD3E", "CD8A", "CD8B")
#' result <- identify_celltype(markers, llm = "claude")
#' }
#'
#' @seealso
#' \code{\link{identify_celltype}}
#'
#' @export
set_api_key <- function(service, api_key) {
  
  # Validate inputs
  if(missing(service)) stop("service parameter is required")
  if(missing(api_key)) stop("api_key parameter is required")
  
  if(!is.character(service) || length(service) != 1) {
    stop("service must be a single character string")
  }
  
  if(!is.character(api_key) || length(api_key) != 1) {
    stop("api_key must be a single character string")
  }
  
  # Validate service parameter
  valid_services <- c("claude", "gemini", "chatgpt")
  if(!service %in% valid_services) {
    stop("service must be one of: ", paste(valid_services, collapse = ", "))
  }
  
  # Validate API key is not empty
  if(nchar(trimws(api_key)) == 0) {
    stop("api_key cannot be empty")
  }
  
  # Set environment variable based on service
  env_var <- switch(service,
    "claude" = "ANTHROPIC_API_KEY",
    "gemini" = "GEMINI_API_KEY", 
    "chatgpt" = "OPENAI_API_KEY"
  )
  
  # Set the environment variable
  Sys.setenv(setNames(api_key, env_var))
  
  # Confirm the key was set
  message("API key set successfully for ", service, " service")
  message("Environment variable: ", env_var)
  
  invisible(TRUE)
}