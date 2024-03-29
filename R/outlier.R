#' Outlier test
#'
#' A simple test for outliers. This functions returns all extreme values (if any) found in the specified vector.
#'
#' @param x a numeric vector of values
#' @return vector of outlier values
#' @examples \dontrun{
#' rp.outlier(mtcars$hp)
#' rp.outlier(c(rep(1,100), 200))
#' rp.outlier(c(rep(1,100), 200,201))
#' }
#' @references {
#' Credit goes to PaulHurleyuk: \url{https://stackoverflow.com/a/1444548/564164}
#'
#' \itemize{
#'  \item Lund, R. E. 1975, "Tables for An Approximate Test for Outliers in Linear Models", Technometrics, vol. 17, no. 4, pp. 473-476.
#'  \item Prescott, P. 1975, "An Approximate Test for Outliers in Linear Models", Technometrics, vol. 17, no. 1, pp. 129-132.
#' }
#' }
#' @export
#' @importFrom stats qf lm rstandard
rp.outlier <- function(x) {
    if (!is.numeric(x)) stop('Wrong variable type (!numeric) provided.')

    lundcrit<-function(a, n, q) {
        ## Calculates a Critical value for Outlier Test according to Lund
        ## See Lund, R. E. 1975, "Tables for An Approximate Test for Outliers in Linear Models", Technometrics, vol. 17, no. 4, pp. 473-476.
        ## and Prescott, P. 1975, "An Approximate Test for Outliers in Linear Models", Technometrics, vol. 17, no. 1, pp. 129-132.
        ## a = alpha
        ## n = Number of data elements
        ## q = Number of independent Variables (including intercept)
        ## --------------------------------------------------------------
        ## Credit goes to PaulHurleyuk: \url{https://stackoverflow.com/a/1444548/564164}
        F<-qf(c(1-(a/n)),df1=1,df2=n-q-1,lower.tail=TRUE)
        crit<-((n-q)*F/(n-q-1+F))^0.5
        crit
    }

    model <- lm(x ~ 1)
    crit <- suppressWarnings(lundcrit(0.1, length(x), length(model$coefficients)))
    if (!is.na(crit))
        return(x[which(abs(rstandard(model)) > crit)])
    else
        return()
}
