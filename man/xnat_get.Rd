% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/xnat_get.R
\name{xnat_get}
\alias{xnat_get}
\title{xnat_get}
\usage{
xnat_get(url, username, password)
}
\arguments{
\item{url}{The URL representing the API endpoint}

\item{username}{The user's alias or username}

\item{password}{The user's secret or password}
}
\value{
A data.frame containing the data from the API endpoint
}
\description{
Retrieves data from the XNAT server's API endpoint. A user can
interact with this function directly by adding their username and password or
alias and secret.
}
\details{
Retrieves data from the XNAT server's API endpoint. A user can
interact with this function directly by adding their username and password or
alias and secret.
}
\seealso{
\code{\link[httr]{GET}}, \code{\link[httr]{authenticate}}, \code{\link[httr]{http_error}}, \code{\link[httr]{status_code}}, \code{\link[httr]{content}}, , \code{\link[httr]{config}}
 \code{\link[jsonlite]{toJSON, fromJSON}}
}
