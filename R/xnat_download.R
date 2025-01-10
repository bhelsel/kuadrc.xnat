#' @title xnat_download
#' @description Downloads scans from the XNAT image scan's API endpoint. A user can
#' interact with this function directly by adding their username and password or
#' alias and secret. 
#' @param outdir A location to download the scan to in the user's directory.
#' @param ... The user can optionally pass their username and password directly to the `xnat_download`
#'     function instead of setting up an alias and secret. If `username` and `password` are not arguments
#'     in the `xnat_download` function then the user will be prompted to create credentials.
#' @return A character value containing the location of the downloads
#' @details Downloads scans from the XNAT image scan's API endpoint. A user can
#' interact with this function directly by adding their username and password or
#' alias and secret. 
#' @seealso 
#'  \code{\link[httr]{GET}}, \code{\link[httr]{authenticate}}, \code{\link[httr]{http_error}}, \code{\link[httr]{status_code}}, \code{\link[httr]{content}}
#'  \code{\link[jsonlite]{toJSON, fromJSON}}
#' @rdname xnat_download
#' @export 
#' @importFrom httr GET authenticate http_error status_code write_disk
#' @importFrom jsonlite fromJSON


xnat_download <- function(outdir, ...){
  
  params <- list(...)
  if(!"username" %in% names(params) & !"password" %in% names(params)){
    credentials <- validate_credentials(...)
  }
  server <- validate_server(...)
  alias <- ifelse(!is.null(params$username), params$username, credentials$alias)
  secret <- ifelse(!is.null(params$password), params$password, credentials$secret)
  
  projects <- get_projects()
  
  if(is.null(params$project) & is.null(params$experiment)){
    project_no <- 
      utils::menu(
        title = "What project do you want to download imaging data for?",
        choices = paste0(projects$secondary_ID, ": ", projects$name)
    )
    params$project <- projects[project_no, "ID"]
  }
  
  params$projectLabel <- projects[projects$ID == params$project, "secondary_ID"]
  
  subjects <- get_subjects(project = params$project)
  
  if(is.null(params$subject) & is.null(params$experiment)){
    subject_no <- 
      utils::menu(
        title = "What subject do you want to download imaging data for?",
        choices = unlist(lapply(strsplit(subjects$label, "_"), FUN = function(x) x[2])) 
      )
    params$subject <- strsplit(subjects[subject_no, "label"], "_")[[1]][2]
  }
  
  experiments <- get_experiments(project = params$project, subject = params$subject)
  
  if(is.null(params$experiment)){
    if(nrow(experiments) == 1){
      params$experiment <- experiments$ID
      params$experimentLabel <- experiments$label
    } else{
      experiment_no <- 
        utils::menu(
          title = "What experiment do you want to download imaging data for?",
          choice = experiments$ID
        )
      params$experiment <- experiments[experiment_no, "ID"]
      params$experimentLabel  <- experiments[experiment_no, "label"]
    }
  }
  
  scans <- get_scans(project = params$project, subject = params$subject, experiment = params$experiment)
  
  if(!is.null(params$scan)){
    url <- construct_url(server = server, experiments = params$experiment)
    if("all" %in% tolower(params$scan)){
      url <- file.path(url, "scans/ALL/files?format=zip")
    } else{
      if(length(params$scan) > 1){
        params$scan <- paste0(grep(paste0(params$scan, collapse = "|"), scans$type), collapse = ",")
      }
      url <- file.path(url, "scans", params$scan, "files?format=zip")
    }
  }
  
  if(is.null(params$scan)){
    types <- c(scans$type, "ALL")
    scan_no <-
      utils::menu(
        title = "What scans do you want to download imaging data for?",
        choices = types
      )
    url <-
      construct_url(
        server = server, projects = params$project,
        subjects = params$subject, experiments = params$experiment
        )
    if("all" %in% tolower(params$scan)){
      url <- file.path(url, "scans/ALL/files?format=zip")
    } else{
      url <- file.path(url, "scans", scan_no, "files?format=zip")
    }
  }
  
  if(!dir.exists(outdir)) dir.create(outdir)
  
  if(!dir.exists(file.path(outdir, params$projectLabel))){
    dir.create(file.path(outdir, params$projectLabel))
    }
  
  outdir <- file.path(outdir, params$projectLabel)
  
  file <- file.path(outdir, sprintf("%s.zip", params$experimentLabel))
  
  tryCatch({
    response <- httr::GET(
      url = url,
      httr::authenticate(user = alias, password = secret),
      httr::write_disk(
        path = file,
        overwrite = TRUE)
      )
    
   if(httr::http_error(response)){
      status <- httr::status_code(response)
      stop(sprintf("Request failed with status code: %s", status))
      }

    unzip_xnat_files(outdir = outdir, zip_file = file)
    
    folder <- gsub(".zip$", "", file)
    
    message(
      "Your downloaded data is stored in this folder:\n\n", folder
    )
  
    }, error = function(e) {

      message("An error occurred: ", e$message)
      return(NULL)
    })
  
  return(folder)
  
  }



