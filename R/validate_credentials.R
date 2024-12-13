#' @title validate_credentials
#' @description Search for and validate the user's XNAT access token credentials.
#' @param ... Optional arguments of server, alias, and secret can be added. This
#' function will validate credentials based on the server, alias, and secret
#' stored in the R environment file if these parameters are not added.
#' @return A list containing the server and user's validated access credentials.
#' @details Search for and validate the user's XNAT access token credentials.
#' @seealso
#'  \code{\link[httr]{GET}}, \code{\link[httr]{authenticate}}, \code{\link[httr]{BROWSE}}, \code{\link[httr]{content}}
#'  \code{\link[utils]{menu}}
#' @rdname validate_credentials
#' @export
#' @importFrom httr GET authenticate BROWSE content
#' @importFrom utils menu

validate_credentials <- function(...){

  credentials <- list(...)

  if(is.null(credentials$alias)) alias <- Sys.getenv("XNAT_ALIAS")

  if(is.null(credentials$secret)) secret <- Sys.getenv("XNAT_SECRET")

  server <- validate_server()
  
  token <- list(alias = alias, secret = secret)

  is_valid <- FALSE

  if(alias != "" & secret != ""){
    validation_url <- sprintf(
      "%s/data/services/tokens/validate/%s/%s",
      server, alias, secret
    )

    validation_results <- httr::GET(
      url = validation_url,
      httr::authenticate(user = alias, password = secret)
    )

    is_valid <- ifelse(validation_results$status_code == 200, TRUE, FALSE)
  }

  if(!is_valid){

    auth_response <-
      utils::menu(
        title = paste0(
          "It looks like your alias and secret are missing or expired.\n\n",
          "Would you like the kuadrc.xnat R package to help you create new credentials?\n\n",
          "It would require you to enter your username and password for authentication to generate a\n",
          "new alias token on ", server, " to be stored in your R environment"),
        choices = c("Yes, I will enter my username and password in R",
                    "Yes, but I would like to enter my username and password in a web browser",
                    "No, I am not interested")
      )

    if(auth_response == 1){
      status_code <- iteration <- 0
      while(status_code != 200){
        iteration <- iteration + 1
        username <- readline(prompt = "Please enter your username: ")
        password <- readline(prompt = "Please enter your password: ")
        token <- httr::GET(
          url = sprintf("%s/data/services/tokens/issue", server),
          httr::authenticate(user = username, password = password)
        )
        status_code <- token$status_code
        token <- httr::content(token)
        if(status_code != 200) message("Incorrect username or password.\n")
        if(iteration >= 2){
          try_again_response <-
            utils::menu(
              title = paste0(
                "Would you like to try logging into ", server, " from a web browser?"
              ),
              choice = c("Yes", "No")
            )
          if(try_again_response == 1){
            to_alias <- "app/template/XDATScreen_UpdateUser.vm#tab=alias-token-tab"
            httr::BROWSE(url = sprintf("%s", server))
            continue <- readline(
              prompt = sprintf("Press enter to continue when you are logged into %s ", server)
              )
            httr::BROWSE(url = sprintf("%s/%s", server, to_alias))
            message(
              "Please navigate to the 'Manage Alias Tokens' tab and select 'Create Alias Token'.\n",
              "Once you see a new alias appear on your screen, click 'View' under the 'Actions' column.\n\n",
              "Copy and paste your 'alias' and 'secret' into R.\n"
            )
            repeat{
              token$alias <- readline(prompt = "Alias: ")
              if (nzchar(token$alias)) break
            }
            repeat{
              token$secret <- readline(prompt = "Secret: ")
              if (nzchar(token$secret)) break
            }
            status_code <- 200
          }
        }
      }
    } else if(auth_response == 2){
      to_alias <- "app/template/XDATScreen_UpdateUser.vm#tab=alias-token-tab"
      httr::BROWSE(url = sprintf("%s", server))
      continue <- readline(
        prompt = sprintf("Press enter to continue when you are logged into %s ", server)
      )
      httr::BROWSE(url = sprintf("%s/%s", server, to_alias))
      message(
        "Please navigate to the 'Manage Alias Tokens' tab and select 'Create Alias Token'.\n",
        "Once you see a new alias appear on your screen, click 'View' under the 'Actions' column.\n\n",
        "Copy and paste your 'alias' and 'secret' into R.\n"
        )
      repeat{
        token$alias <- readline(prompt = "Alias: ")
        if (nzchar(token$alias)) break
      }
      repeat{
        token$secret <- readline(prompt = "Secret: ")
        if (nzchar(token$secret)) break
      }

    } else{
      stop("You chose to not authenticate your credentials at this time.")
    }

    add_alias(token$alias, force_update = TRUE)

    add_secret(token$secret, force_update = TRUE)

    expiresAt <- as.POSIXct(
      token$estimatedExpirationTime / 1000,
      origin = "1970-01-01",
      tz = Sys.timezone(),
    )

    message(
        sprintf(
          "New token was generated for '%s' and stored in the R environment.",
          token$xdatUserId
        ),
        sprintf(
          "\nThe new token will expire on %s at %s\n",
          format(expiresAt, "%A, %B %d, %Y"),
          format(expiresAt, "%I:%M:%S %p %Z")
        )
    )
  }

  return(list(server = server, alias = token$alias, secret = token$secret))

}
