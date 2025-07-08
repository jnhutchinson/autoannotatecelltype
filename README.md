# autoannotatecelltype

An R package for automated cell type annotation using AI models (Claude, Gemini, and ChatGPT).

## Overview

This package provides automated cell type annotation functionality using large language models to identify cell types from marker gene lists. It's designed for single-cell RNA sequencing analysis workflows and supports multiple species and tissue contexts.

## Installation

You can install the development version from GitHub:

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install autoannotatecelltype
devtools::install_github("jnhutchinson-diamondage/autoannotatecelltype")
```

## Setup

Before using the package, you need to set up API keys for your preferred AI service:

```r
library(autoannotatecelltype)

# Set API key for Claude (Anthropic)
set_api_key("claude", "your-anthropic-api-key")

# Or for Gemini
set_api_key("gemini", "your-gemini-api-key")

# Or for ChatGPT (OpenAI)
set_api_key("chatgpt", "your-openai-api-key")
```

## Usage

### Basic Usage

```r
# Define marker genes
markers <- c("CD3D", "CD3E", "CD8A", "CD8B", "GZMB", "PRF1")

# Identify cell type using Claude (default)
result <- identify_celltype(markers)

# With tissue context for better accuracy
result <- identify_celltype(markers, tissue_context = "peripheral blood")
```

### Using Different AI Models

```r
# Using Gemini
result <- identify_celltype(markers, llm = "gemini")

# Using ChatGPT
result <- identify_celltype(markers, llm = "chatgpt")

# Using specific models
result <- identify_celltype(markers, llm = "claude", model = "claude-3-opus-20240229")
result <- identify_celltype(markers, llm = "gemini", model = "gemini-1.5-pro")
result <- identify_celltype(markers, llm = "chatgpt", model = "gpt-4o")
```

### Different Species

```r
# Mouse genes
mouse_markers <- c("Cd3d", "Cd3e", "Cd8a", "Cd8b")
result <- identify_celltype(mouse_markers, species = "mouse")
```

### Saving Results

```r
# Save results to file
result <- identify_celltype(markers, save_results = TRUE)

# Or specify custom filename
result <- identify_celltype(markers, save_results = TRUE, output_file = "my_results.rds")
```

## Supported Models

### Claude (Anthropic)
- `claude-3-5-sonnet-20241022` (default)
- `claude-3-opus-20240229`
- `claude-3-haiku-20240307`

### Gemini (Google)
- `gemini-1.5-pro`
- `gemini-1.5-flash`
- `gemini-1.0-pro`

### ChatGPT (OpenAI)
- `gpt-4o`
- `gpt-4-turbo`
- `gpt-4`
- `gpt-3.5-turbo`

## Supported Species

- `human` (default)
- `mouse`
- `rat`
- `zebrafish`
- `drosophila`

## API Key Security

For security, avoid hardcoding API keys in scripts. Consider using:

- `.Renviron` file in your home directory
- Environment variables set in your shell
- R's `keyring` package for secure credential storage

## Dependencies

- `ellmer` - For AI model communication
- `glue` - For prompt construction

## License

MIT License

## Contributing

Issues and pull requests are welcome on GitHub.