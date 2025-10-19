

source("config.R")

# Get remote server directory list function
get_remote_dirs <- function(remote_user, remote_host, remote_path) {
  
  # Build SSH command to list remote directories
  ssh_command <- paste0(remote_user, "@", remote_host)
  ls_command <- paste0("ls -1 ", remote_path)
  
  result <- system2("ssh", 
                    args = c(ssh_command, ls_command), 
                    stdout = TRUE, 
                    stderr = TRUE)
  
  # Check for errors
  if(!is.null(attr(result, "status"))) {
    warning("SSH command failed")
    return(character(0))
  }
  
  # Filter directories (optional)
  dirs <- result[result != ""]
  return(dirs)
}

remote_path <- paste0(github_repo, "/", output_dir)

# Get subdirectories from remote server
remote_subdirs <- get_remote_dirs(remote_user, remote_host, remote_path)

for(model_name in remote_subdirs )  {
  
  remote_dir <- paste0(github_repo,"/",output_dir,"/",model_name)
  
  CondorBox::BatchFileHandler(
    remote_user   = remote_user,
    remote_host   = remote_host,
    folder_name   = remote_dir,
    action        = "fetch",
    fetch_dir     =  "model",
    extract_archive = TRUE,
    direct_extract = TRUE,
    archive_name    = "output_archive.tar.gz",  # Archive file to extract
    extract_folder  = paste0(github_repo,"/model")
  )
  
}
