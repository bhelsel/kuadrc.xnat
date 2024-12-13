#' @title construct_url
#' @description Helps construct the URL to retrieve projects, subjects, experiments,
#' and scans from the XNAT API endpoints
#' @param server A character argument containing a URL starting with "https://"
#' followed by the university's XNAT server (e.g., "https://xnat.university.edu")
#' @param projects A project number in which a user has access, Default: NULL
#' @param subjects A subject identifier, Default: NULL
#' @param experiments A numeric value corresponding to the subject's experiment or session, Default: NULL
#' @return A character value containing a formatted URL to the XNAT API endpoint
#' @details Helps construct the URL to retrieve projects, subjects, experiments,
#' and scans from the XNAT API endpoints
#' @rdname construct_url
#' @export

construct_url <- function(server,
    projects = NULL, subjects = NULL,
    experiments = NULL){

  url <- paste0(server, "/data")

  if(!is.null(projects) & is.null(subjects) & is.null(experiments)){
    url <- sprintf("%s/projects/%s", url, projects)
  } else if((is.null(projects) | is.null(subjects)) & !is.null(experiments)){
    url <- sprintf("%s/experiments/%s", url, experiments)
  } else if(!is.null(projects) & !is.null(subjects) & is.null(experiments)){
    subjects <- sprintf("%s_%s", projects, subjects)
    url <- sprintf(
      "%s/projects/%s/subjects/%s",
      url, projects, subjects
      )
  } else if(!is.null(projects) & !is.null(subjects) & !is.null(experiments)){
    subjects <- sprintf("%s_%s", projects, subjects)
    url <- sprintf(
      "%s/projects/%s/subjects/%s/experiments/%s",
      url, projects, subjects, experiments
    )
  }

  return(url)
}

