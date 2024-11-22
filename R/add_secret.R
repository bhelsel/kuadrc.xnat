#' @title add_secret
#' @description This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add or update their
#' secret as a variable in their computer's R environment.
#' @param secret A character argument containing an secret generated from the XNAT website
#' @param force_update This boolean value provides an option to skip the utils::menu selection, Default: FALSE
#' @return This function does not return any values.
#' @details This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add or update their
#' secret as a variable in their computer's R environment.
#' @seealso
#'  \code{\link[utils]{menu}}
#' @rdname add_secret
#' @export
#' @importFrom utils menu

add_secret <- function(secret, force_update = FALSE){
  if(Sys.getenv("XNAT_SECRET") == ""){
    message("No XNAT_SECRET detected in your R environment.\n")
    response <-
      utils::menu(
        title = sprintf('Do you want to add %s as your secret?', secret),
        choices = c("Yes", "No")
      )
    if(response == 1){
      Sys.setenv(XNAT_SECRET = secret)
      tryCatch({
        renv <- c(readLines("~/.Renviron"), sprintf("XNAT_SECRET = '%s'", secret))
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('\nWe stored %s as a\nsecret in your R environment', secret),
        'It can be accessed using Sys.getenv("XNAT_SECRET")\n'
      )
    } else if(response == 2){
      message(
        'No problem! We will not add it right now, but you will need to add it\n',
        'each time you make a call to the XNAT API with the kuadrc.xnat R package.'
      )
    } else if(response == 0){
      message("You chose to exit the program.")
    }
  } else if (Sys.getenv("XNAT_SECRET") == secret){
    message(
      'The secret you entered matches the secret stored in your R\nenvironment. ',
      'It can be accessed using Sys.getenv("XNAT_SECRET")'
    )
  } else if(Sys.getenv("XNAT_SECRET") != secret){
    message(
        sprintf('The secret you entered (%s) and the one ', secret),
        sprintf('stored\nin your R environment (%s) do not match.', Sys.getenv("XNAT_SECRET"))
    )
    if(force_update){
      response <- 1
    } else{
      response <-
        utils::menu(
          title = sprintf('Would you like to update your R environment to the %s secret?', secret),
          choices = c("Yes", "No")
        )
    }
    if(response == 1){
      Sys.setenv(XNAT_SECRET = secret)
      tryCatch({
        renv <- readLines("~/.Renviron")
        renv[grep("XNAT_SECRET", renv)] <- sprintf("XNAT_SECRET = '%s'", secret)
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('\nWe stored %s in your R environment', secret),
        '\nIt can be accessed using Sys.getenv("XNAT_SECRET")\n'
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
