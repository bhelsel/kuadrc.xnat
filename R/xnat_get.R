#' @title xnat_get
#' @description Retrieves data from the XNAT server's API endpoint. A user can
#' interact with this function directly by adding their username and password or
#' alias and secret. 
#' @param url The URL representing the API endpoint
#' @param username The user's alias or username
#' @param password The user's secret or password
#' @return A data.frame containing the data from the API endpoint
#' @details Retrieves data from the XNAT server's API endpoint. A user can
#' interact with this function directly by adding their username and password or
#' alias and secret.
#' @seealso 
#'  \code{\link[httr]{GET}}, \code{\link[httr]{authenticate}}, \code{\link[httr]{http_error}}, \code{\link[httr]{status_code}}, \code{\link[httr]{content}}
#'  \code{\link[jsonlite]{toJSON, fromJSON}}
#' @rdname xnat_get
#' @export 
#' @importFrom httr GET authenticate http_error status_code content
#' @importFrom jsonlite fromJSON

xnat_get <- function(url, username, password){
  
  tryCatch({
    response <- httr::GET(
      url = url, 
      httr::authenticate(user = username, password = password)
      )
    
    if(httr::http_error(response)){
      status <- httr::status_code(response)
      stop(sprintf("Request failed with status code: %s", status))
    }
    
    response_data <- as.data.frame(
      jsonlite::fromJSON(
        httr::content(
          response, 
          as = "text", 
          encoding = "UTF-8")
        )
      )
      
    return(response_data)
    
  }, error = function(e) {
    
    message("An error occurred: ", e$message)
    return(NULL)
  })
}
