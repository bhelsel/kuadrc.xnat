#' @title add_server
#' @description This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add their university
#' XNAT server as a variable in their computer's R environment.
#' @param server A character argument containing a URL starting with "https://"
#' followed by the university's XNAT server (e.g., "https://xnat.university.edu")
#' @param force_update This boolean value provides an option to skip the utils::menu selection, Default: FALSE
#' @return This function does not return any values.
#' @details This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add their university
#' XNAT server as a variable in their computer's R environment.
#' @seealso
#'  \code{\link[utils]{menu}}
#' @rdname add_server
#' @export
#' @importFrom utils menu

add_server <- function(server, force_update = FALSE){
  if(Sys.getenv("XNAT_SERVER") == ""){
    message("No XNAT_SERVER detected in your R environment.\n")
    response <-
      utils::menu(
        title = sprintf('Do you want to add %s?', server),
        choices = c("Yes", "No")
      )
    if(response == 1){
      Sys.setenv(XNAT_SERVER = server)
      tryCatch({
        renv <- c(readLines("~/.Renviron"), sprintf("XNAT_SERVER = '%s'", server))
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('Great! We stored %s in your R environment', server),
        '\nIt can be accessed using Sys.getenv("XNAT_SERVER")\n'
      )
    } else if(response == 2){
      message(
        'No problem! We will not add it right now, but you will need to add it\n',
        'each time you make a call to the XNAT API with the kuadrc.xnat R package.'
      )
    } else if(response == 0){
      message("You chose to exit the program.")
    }
  } else if (Sys.getenv("XNAT_SERVER") == server){
    message(
      'The server you entered matches the server stored in your R environment',
      '\nIt can be accessed using Sys.getenv("XNAT_SERVER")'
    )
  } else if(Sys.getenv("XNAT_SERVER") != server){
    message(
      sprintf('The server you entered (%s) and the one ', server),
      sprintf('stored in your\nR environment (%s) do not match.', Sys.getenv("XNAT_SERVER"))
    )
    if(force_update){
      response <- 1
    } else{
      response <-
        utils::menu(
          title = sprintf('Would you like to update your R environment to the %s server?', server),
          choices = c("Yes", "No")
        )
    }
    if(response == 1){
      Sys.setenv(XNAT_SERVER = server)
      tryCatch({
        renv <- readLines("~/.Renviron")
        renv[grep("XNAT_SERVER", renv)] <- sprintf("XNAT_SERVER = '%s'", server)
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('Great! We stored %s in your R environment', server),
        '\nIt can be accessed using Sys.getenv("XNAT_SERVER")'
      )
    } else if(response == 2){
      message(
        'No problem! We will not add it right now, but you will need to add it\n',
        'each time you make a call to the XNAT API with the kuadrc.xnat R package.'
      )
    } else if(response == 0){
      message("You chose to exit the program.")
    }
  }
}
