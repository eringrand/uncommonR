% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/school_year.R
\name{sy_form}
\alias{sy_form}
\title{sy_form}
\usage{
sy_form(school_year, spring_year = TRUE)
}
\arguments{
\item{school_year}{school year in the form of a number}

\item{spring_year}{If the given year represents the Spring portion then TRUE. Defaults to TRUE}
}
\description{
Takes a value in the form of a number (i.e. 2017)
and converts to 2016-17. The opposite of `sy_number` with 20 instead of SY.
}
\examples{
sy_form("2015")
}
\seealso{
\code{\link{change_school_year}} \code{\link{sy_form}} \code{\link{sy_number}}
}
