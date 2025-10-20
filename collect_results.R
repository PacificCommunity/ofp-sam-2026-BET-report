# ============================================================
# Fetch remote MFCL model outputs and save locally per model
# ============================================================

library(dplyr)
library(tidyr)
library(reshape2)
library(FLR4MFCL)
library(purrr)
library(stringr)

source("config.R")  # Load user-specific settings (github_repo, remote_user, etc.)

# ------------------------------------------------------------
# 1. Function to list directories on remote server via SSH
# ------------------------------------------------------------
get_remote_dirs <- function(remote_user, remote_host, remote_path) {
  ssh_command <- paste0(remote_user, "@", remote_host)
  ls_command  <- paste0("ls -1 ", remote_path)
  
  result <- system2("ssh", args = c(ssh_command, ls_command),
                    stdout = TRUE, stderr = TRUE)
  
  if (!is.null(attr(result, "status"))) {
    warning("SSH command failed")
    return(character(0))
  }
  
  dirs <- result[result != ""]
  return(dirs)
}

# ------------------------------------------------------------
# 2. Fetch remote model folders
# ------------------------------------------------------------
remote_path    <- paste0(github_repo, "/", output_dir)
remote_subdirs <- get_remote_dirs(remote_user, remote_host, remote_path)

for(model_name in remote_subdirs) {
  remote_dir <- paste0(github_repo, "/", output_dir, "/", model_name)
  
  CondorBox::BatchFileHandler(
    remote_user      = remote_user,
    remote_host      = remote_host,
    folder_name      = remote_dir,
    action           = "fetch",
    fetch_dir        = "model",
    extract_archive  = TRUE,
    direct_extract   = TRUE,
    archive_name     = "output_archive.tar.gz",
    extract_folder   = paste0(github_repo, "/model")
  )
}

# ------------------------------------------------------------
# 3. Determine top-level folder (e.g., 'sens' or 'grid')
# ------------------------------------------------------------
top_dir <- strsplit(output_dir, "/")[[1]][1]

# ------------------------------------------------------------
# 4. Define local directories
# ------------------------------------------------------------
model_dir <- file.path(getwd(), "model")                  # Local extracted models
out_dir   <- file.path(getwd(), "results_rds", top_dir)  # Save RDS per model

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
# ------------------------------------------------------------
# 5. Process and save each model folder
# ------------------------------------------------------------
model_folders <- list.dirs(model_dir, full.names = TRUE, recursive = FALSE)

walk(model_folders, function(folder) {
  
  outputs_path <- normalizePath(folder, winslash = "/", mustWork = FALSE)
  cat("Processing folder:", outputs_path, "\n")
  
  # Extract model folder name (e.g., 'base', 'fixK', 'noAge')
  model_name <- basename(folder)
  
  # ---------------------------
  # Read MFCL outputs
  # ---------------------------
  ParOut <- read.MFCLPar(finalPar(outputs_path))
  RepOut <- read.MFCLRep(finalRep(outputs_path))
  
  output_files    <- list.files(outputs_path, pattern = "^test_plot_output_\\d+$", full.names = TRUE)
  LikOut_list     <- map(output_files, read.MFCLLikelihood)
  LikRawOut_list  <- map(output_files, readLines)
  
  # Extract numeric suffix for LikOut naming
  scales <- basename(output_files) %>% str_extract("\\d+$")
  names(LikOut_list)    <- scales
  names(LikRawOut_list) <- scales
  
  # ---------------------------
  # Read info.rds if it exists
  # ---------------------------
  info_file <- file.path(outputs_path, "info.rds")
  if (file.exists(info_file)) {
    info <- readRDS(info_file)
  } else {
    info <- NULL
  }
  
  # ---------------------------
  # Combine results for this model
  # ---------------------------
  model_result <- list(
    ParOut      = ParOut,
    RepOut      = RepOut,
    LikOut      = LikOut_list,
    LikRawOut   = LikRawOut_list,
    scales      = scales,
    model_name  = model_name,
    parent_dir  = remote_path,
    info        = info  # add info.rds content
  )
  
  # ---------------------------
  # Save model result as compressed .rds
  # ---------------------------
  saveRDS(model_result,
          file = file.path(out_dir, paste0(model_name, ".rds")),
          compress = "xz")
  
  cat("✅ Saved model:", model_name, "\n")
})

cat("\nAll model results have been saved in:", out_dir, "\n")


# ------------------------------------------------------------
# Save collection info as a human-readable stamp
# ------------------------------------------------------------

# Path to human-readable collection stamp
stamp_file <- file.path(getwd(), "collect_done.txt")


# Prepare lines for the stamp file
stamp_lines <- c(
  paste0("Collection timestamp: ", Sys.time()),                         # Current date and time of collection
  paste0("Working directory   : ", getwd()),                             # Current working directory
  paste0("Model directory     : ", model_dir),                            # Directory containing model folders
  paste0("Results directory   : ", out_dir),                          # Directory where results are stored
  "Processed folders:",                                                    # Header for folder list
  paste0("  - ", basename(model_folders)),                                # Names of each processed model folder
  paste0("Number of models    : ", length(model_folders)),                # Total number of processed models
  paste0("R version           : ", R.version.string),                     # R version used for reproducibility
  paste0("Platform            : ", R.version$platform)                     # Platform/OS information
)

# Write the information to the stamp file
writeLines(stamp_lines, stamp_file)
cat("\n✅ Collection complete. Metadata saved in", stamp_file, "\n")
