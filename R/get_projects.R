#' @title get_projects
#' @description Retrieves a user's projects from the API endpoint
#' @param name An optional name can be provided to only return the project number, Default: NULL
#' @param ... Optional parameters that can include updated server, alias, and secret values that
#' will be added to a user's R environment. A user can also provide their username and password
#' as arguments to interact with the API without using an alias and secret.
#' @return A data set of the user's approved projects or a character value if name
#' uniquely matches a study label in the data set. If name matches more than one
#' value in the data set, this function will return all values.
#' @details Retrieves a user's projects from the API endpoint
#' @rdname get_projects
#' @export

get_projects <- function(name = NULL, ...){

  params <- list(...)
  credentials <- validate_credentials(...)
  server <- credentials$server
  alias <- ifelse(!is.null(params$username), params$username, credentials$alias)
  secret <- ifelse(!is.null(params$password), params$password, credentials$secret)

  data <- xnat_get(
    url = sprintf("%s/data/projects", server),
    username = alias, password = secret
  )

  colnames(data) <- gsub("ResultSet.|Result.", "", colnames(data))

  data <- data[!data$secondary_ID %in% c("Prj.Template", "xnat_qc_test"), -which(colnames(data) == "totalRecords")]

  if(!is.null(name)){
    data <- data[grepl(name, data$secondary_ID, ignore.case = TRUE) |
                   grepl(name, data$name, ignore.case = TRUE), "ID"]
  }

  return(data)
}
