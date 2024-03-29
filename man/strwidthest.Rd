% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/strwidth.R
\name{strwidthest}
\alias{strwidthest}
\title{Estimate string width}
\usage{
strwidthest(s)
}
\arguments{
\item{s}{string}
}
\value{
numeric value representing the total width of the provided string in millimeters
}
\description{
Pre-computed width of strings without actually calling to \pkg{graphics} and \code{new.plot}. The function can only handle base ASCII characters and default width of those is estimated by using standard 12 pt \code{serif} on a standard \code{plot}. Non-ASCII characters are replaced by an underscore.
}
\examples{
\dontrun{
strwidthrel('R') # 71
strwidthrel('R is awesome!') # 635
}
}
