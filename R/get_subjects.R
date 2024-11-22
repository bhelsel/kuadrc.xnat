#' @title get_subjects
#' @description Retrieves all subjects or subjects from specific projects
#' @param project An optional project number can be provided to only return the experiments within that specific project, Default: NULL
#' @param subject An optional subject number can be provided to only return information from a certain subject, Default: NULL
#' @param ... Optional parameters that can include updated server, alias, and secret values that
#' will be added to a user's R environment. A user can also provide their username and password
#' as arguments to interact with the API without using an alias and secret.
#' @return A data set of the user's approved experiments or a character value if experiment
#' uniquely matches an experiment label in the data set. If name matches more than one
#' value in the data set, this function will return all values.
#' @details Retrieves all subjects or subjects from specific projects
#' @rdname get_subjects
#' @export


get_subjects <- function(project = NULL, subject = NULL, ...){

  params <- list(...)
  credentials <- validate_credentials(...)
  server <- credentials$server
  alias <- ifelse(!is.null(params$username), params$username, credentials$alias)
  secret <- ifelse(!is.null(params$password), params$password, credentials$secret)

  if(is.null(project)){
    url <- paste0(server, "/data")
  } else{
    url <- construct_url(server, projects = project)
  }

  data <- xnat_get(
    url = paste0(url, "/subjects"),
    username = alias,
    password = secret
  )

  colnames(data) <- gsub("ResultSet.|Result.", "", colnames(data))

  if(!is.null(subject)){
    data <- data[grepl(subject, data$label, ignore.case = TRUE), "label"]
  }

  return(data)

}

