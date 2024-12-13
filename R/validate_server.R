#' @title validate_credentials
#' @description Search for and validate the user's XNAT server.
#' @param ... Optional arguments of server can be added. This
#' function will validate credentials based on the server
#' stored in the R environment file if these parameters are not added.
#' @return The server entered by the user or stored in the user's R environment.
#' @details Search for and validate the user's XNAT server.
#' @rdname validate_server
#' @export

validate_server <- function(...){
  
  credentials <- list(...)
  
  if(is.null(credentials$server)) {
    server <- Sys.getenv("XNAT_SERVER")
    if(server == ""){
      message(
        "We did not find a server in your R environment or your recent call to a kuadrc.xnat function.\n",
        "Please add a server below to continue or select 'esc' and edit the ~/.Renviron file directly.\n\n",
        "An example of a valid server is https://xnat.university.edu where your {server} is substituted for {university}.\n"
      )
      server <- readline(prompt = "Server: ")
      add_server(server); server <- Sys.getenv("XNAT_SERVER")
      }
    } else if("server" %in% names(credentials)){
      add_server(credentials$server); server <- Sys.getenv("XNAT_SERVER")
    }
  return(server)
}
  
