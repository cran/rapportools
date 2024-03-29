% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{is.number}
\alias{is.number}
\title{Numbers}
\usage{
is.number(x, integer = FALSE)
}
\arguments{
\item{x}{an object to check}

\item{integer}{logical: check if number is integer}
}
\value{
a logical value indicating whether provided object is a string
}
\description{
Checks if provided object is a number, i.e. a length-one numeric vector.
}
\examples{
is.number(3)              # [1] TRUE
is.number(3:4)            # [1] FALSE
is.number("3")            # [1] FALSE
is.number(NaN)            # [1] TRUE
is.number(NA_integer_)    # [1] TRUE
}
