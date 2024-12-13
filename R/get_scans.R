#' @title get_scans
#' @description Retrieves all scans or scans from specific projects, subjects, and experiments
#' @param project An optional project number can be provided to only return the experiments within that specific project, Default: NULL
#' @param subject An optional subject number can be provided to only return the experiments for a certain subject, Default: NULL
#' @param experiment An optional experiment number can be provided to only return those experiments, Default: NULL
#' @param scan An optional scan can be provided to only return those scans, Default: NULL
#' @param ... Optional parameters that can include updated server, alias, and secret values that
#' will be added to a user's R environment. A user can also provide their username and password
#' as arguments to interact with the API without using an alias and secret.
#' @return A data set of the user's approved scans or a character value if scan
#' uniquely matches an scan label in the data set. If name matches more than one
#' value in the data set, this function will return all values.
#' @details Retrieves all scans or scans from specific projects, subjects, and experiments
#' @rdname get_scans
#' @export


get_scans <- function(project = NULL, subject = NULL, experiment = NULL, scan = NULL, ...){

  params <- list(...)
  if(!"username" %in% names(params) & !"password" %in% names(params)){
    credentials <- validate_credentials(...)
  }
  server <- validate_server(...)
  alias <- ifelse(!is.null(params$username), params$username, credentials$alias)
  secret <- ifelse(!is.null(params$password), params$password, credentials$secret)

  url <- construct_url(server, projects = project, subjects = subject, experiments = experiment)

  data <- xnat_get(
    url = paste0(url, "/scans"),
    username = alias,
    password = secret
  )

  colnames(data) <- gsub("ResultSet.|Result.", "", colnames(data))

  data <- cbind(
    label = basename(url),
    data[, c("ID", "type", "URI", "quality")]
    )

  if(!is.null(scan)){
    url <- paste0(url, "/scans/", grep(scan, data$type, ignore.case = TRUE))
    data <- data[grep(scan, data$type, ignore.case = TRUE), ]
    return(list(data = data, url = url))
  } else{
    return(data)
  }
}
