#' @title add_alias
#' @description This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add or update their
#' alias as a variable in their computer's R environment.
#' @param alias A character argument containing an alias generated from the XNAT website
#' @param force_update This boolean value provides an option to skip the utils::menu selection, Default: FALSE
#' @return This function does not return any values.
#' @details This is a convenience function to help during the set up of the
#' kuadrc.xnat package. A user can use this function to help add or update their
#' alias as a variable in their computer's R environment.
#' @seealso
#'  \code{\link[utils]{menu}}
#' @rdname add_alias
#' @export
#' @importFrom utils menu

add_alias <- function(alias, force_update = FALSE){
  if(Sys.getenv("XNAT_ALIAS") == ""){
    message("No XNAT_ALIAS detected in your R environment.\n")
    response <-
      utils::menu(
        title = sprintf('Do you want to add %s as your alias?', alias),
        choices = c("Yes", "No")
      )
    if(response == 1){
      Sys.setenv(XNAT_ALIAS = alias)
      tryCatch({
        renv <- c(readLines("~/.Renviron"), sprintf("XNAT_ALIAS = '%s'", alias))
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('\nWe stored %s as an alias in your R\nenvironment. ', alias),
        'It can be accessed using Sys.getenv("XNAT_ALIAS")\n'
      )
    } else if(response == 2){
      message(
        'No problem! We will not add it right now, but you will need to add it\n',
        'each time you make a call to the XNAT API with the kuadrc.xnat R package.'
      )
    } else if(response == 0){
      message("You chose to exit the program.")
    }
  } else if (Sys.getenv("XNAT_ALIAS") == alias){
    message(
      'The alias you entered matches the alias stored in your R\nenvironment. ',
      'It can be accessed using Sys.getenv("XNAT_ALIAS")'
    )
  } else if(Sys.getenv("XNAT_ALIAS") != alias){
    message(
      sprintf('The alias you entered (%s) and the one ', alias),
      sprintf('stored\nin your R environment (%s) do not match.', Sys.getenv("XNAT_ALIAS"))
    )
    if(force_update){
      response <- 1
    } else{
      response <-
        utils::menu(
          title = sprintf('Would you like to update your R environment to the %s alias?', alias),
          choices = c("Yes", "No")
        )
    }
    if(response == 1){
      Sys.setenv(XNAT_ALIAS = alias)
      tryCatch({
        renv <- readLines("~/.Renviron")
        renv[grep("XNAT_ALIAS", renv)] <- sprintf("XNAT_ALIAS = '%s'", alias)
        writeLines(renv, "~/.Renviron")
      }, error = function(e){
        print("We could not locate the '~/.Renviron' file")
      })
      message(
        sprintf('\nWe stored %s in your R\nenvironment. ', alias),
        'It can be accessed using Sys.getenv("XNAT_ALIAS")\n'
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
