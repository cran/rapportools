#' Strings
#'
#' Checks if provided object is a string i.e. a length-one character vector.
#' @param x an object to check
#' @return a logical value indicating whether provided object is a string
#' @examples
#'     is.string("foobar")          # [1] TRUE
#'     is.string(1)                 # [1] FALSE
#'     is.string(c("foo", "bar"))   # [1] FALSE
#' @export
is.string <- function(x){
    is.character(x) && length(x) == 1
}


#' Boolean
#'
#' Checks if provided object is a boolean i.e. a length-one logical vector.
#' @param x an object to check
#' @return a logical value indicating whether provided object is a boolean
#' @examples \dontrun{
#'     is.boolean(TRUE)                # [1] TRUE
#'     # the following will work on most systems, unless you have tweaked global Rprofile
#'     is.boolean(T)                   # [1] TRUE
#'     is.boolean(1)                   # [1] FALSE
#'     is.string(c("foo", "bar"))      # [1] FALSE
#' }
#' @export
is.boolean <- function(x){
    is.logical(x) && length(x) == 1
}


#' Numbers
#'
#' Checks if provided object is a number, i.e. a length-one numeric vector.
#' @param x an object to check
#' @param integer logical: check if number is integer
#' @return a logical value indicating whether provided object is a string
#' @examples
#' is.number(3)              # [1] TRUE
#' is.number(3:4)            # [1] FALSE
#' is.number("3")            # [1] FALSE
#' is.number(NaN)            # [1] TRUE
#' is.number(NA_integer_)    # [1] TRUE
#' @export
is.number <- function(x, integer = FALSE) {
    check.fn <- if (isTRUE(integer)) is.integer else is.numeric
    do.call(check.fn, list(x)) && length(x) == 1
}


#' Variables
#'
#' From \emph{rapport}'s point of view, a \code{variable} is a non-\code{NULL} atomic vector that has no dimension attribute (see \code{dim} for details). This approach bypasses \code{factor} issues with \code{\link{is.vector}}, and also eliminates multidimensional vectors, such as matrices and arrays.
#' @param x an object to be checked for "variable" format
#' @return a logical value indicating that provided object is a "variable"
#' @examples
#' is.variable(rnorm(100))  # [1] TRUE
#' is.variable(LETTERS)     # [1] TRUE
#' is.variable(NULL)        # [1] FALSE
#' is.variable(mtcars)      # [1] FALSE
#' is.variable(HairEyeColor[, , 1])  # [1] FALSE
#' is.variable(list())      # [1] FALSE
#' @export
is.variable <- function(x){
    if (base::missing(x))
        stop('test object not provided')
    is.atomic(x) & !is.null(x) & is.null(dim(x))
}


#' Tabular Structure
#'
#' Checks if object has "tabular" structure (not to confuse with \code{\link{table}}) - in this particular case, that means \code{\link{matrix}} and \code{\link{data.frame}} objects only.
#' @param x an object to be checked for "tabular" format
#' @return a logical value indicating that provided object has tabular structure
#' @examples
#' is.tabular(HairEyeColor[, , 1])  # [1] TRUE
#' is.tabular(mtcars)               # [1] TRUE
#' is.tabular(table(mtcars$cyl))    # [1] FALSE
#' is.tabular(rnorm(100))           # [1] FALSE
#' is.tabular(LETTERS)              # [1] FALSE
#' is.tabular(pi)                   # [1] FALSE
#' @export
is.tabular <- function(x){
    if (base::missing(x))
        stop('no object to test table')
    inherits(x, c('matrix', 'data.frame')) && length(dim(x)) == 2
}


#' Check integers
#'
#' This function tests if given variable "appears" to be an integer. To qualify as such, two conditions need to be satisfied: it should be stored as \code{\link{numeric}} object, and it should pass regular expression test if it consists only of digits.
#' @param x a numeric variable that is to be tested
#' @return a logical value that indicates that tested variable "looks like" integer
#' @export
alike.integer <- function(x){

    if (missing(x))
        stop('no object to test integer')

    is.numeric(x) & all(grepl('^-?[[:digit:]]+$', x))
}


#' Trim Spaces
#'
#' Removes leading and/or trailing space(s) from a character vector. By default, it removes both leading and trailing spaces.
#' @param x a character vector which values need whitespace trimming
#' @param what which part of the string should be trimmed. Defaults to \code{both} which removes trailing and leading spaces. If \code{none}, no trimming will be performed.
#' @param space.regex a character value containing a regex that defines a space character
#' @param ... additional arguments for \code{\link{gsub}} function
#' @return a character vector with (hopefully) trimmed spaces
#' @export
trim.space <- function(x, what = c('both', 'leading', 'trailing', 'none'), space.regex = '[:space:]', ...){
    if (missing(x))
        stop('nothing to trim spaces to =(')
    re <- switch(match.arg(what),
                 both     = sprintf('^[%s]+|[%s]+$', space.regex, space.regex),
                 leading  = sprintf('^[%s]+', space.regex),
                 trailing = sprintf('[%s]+$', space.regex),
                 none     = {
                     return (x)
                 })
    vgsub(re, '', x, ...)
}


#' Percent
#'
#' Appends a percent sign to provided numerical value. Rounding is carried out according to value passed in \code{decimals} formal argument (defaults to value specified in \code{panderOptions('digits')}).
#' @param x a numeric value that is to be rendered to percent
#' @param digits an integer value indicating number of decimal places
#' @param type a character value indicating whether percent or proportion value was provided (partial match is allowed)
#' @param check.value perform a sanity check to see if provided numeric value is correct (defaults to \code{TRUE})
#' @return a character value with formatted percent
#' @export
#' @importFrom pander panderOptions
pct <- function(x, digits = panderOptions('digits'), type = c('percent', '%', 'proportion'), check.value = TRUE){

    if (!is.numeric(x))
        stop('only numeric values should be provided')

    val <- switch(match.arg(type),
                  proportion = {
                      if (check.value)
                          stopifnot(all(x >= 0 & x <= 1))
                      x * 100
                  },
                  '%'=,
                  percent = {
                      if (check.value)
                          stopifnot(all(x >= 0 & x <= 100))
                      x
                  },
                  stop('unsupported number format')
                  )

    dec <- ifelse(is.null(digits), 0, digits)
    fmt <- paste('%.', dec, 'f%%', sep = '')

    sprintf(fmt, val)
}


#' Create Formula from Strings
#'
#' Takes multiple character arguments as left and right-hand side arguments of a formula, and concatenates them in a single string.
#' @param left a string with left-hand side formula argument
#' @param right a character vector with right-hand side formula arguments
#' @param join.left concatenation string for elements of character vector specified in \code{left}
#' @param join.right concatenation string for elements of character vector specified in \code{right}
#' @examples
#' fml("hp", c("am", "cyl"))    # "hp ~ am + cyl"
#' @export
fml <- function(left, right, join.left = ' + ', join.right = ' + '){
    sprintf('%s ~ %s', paste(left, collapse = join.left), paste(right, collapse = join.right))
}


#' Adjacent Values Run Length Encoding
#'
#' Similar to \code{\link{rle}} function, this function detects "runs" of adjacent integers, and displays vector of run lengths and list of corresponding integer sequences.
#' @param x a numeric vector with
#' @return a list with two elements: vector of run lengths, and another list of values corresponding to generated sequences' lengths.
#' @author Gabor Grothendieck <ggrothendieck@@gmail.com>
#' @references See original thread for more details \url{https://stackoverflow.com/a/8467446/564164}. Special thanks to Gabor Grothendieck for this one!
#' @export
adj.rle <- function(x){

    s <- split(x, cumsum(c(0, diff(x) != 1)))
    run.info <- list(lengths = unname(sapply(s, length)), values = unname(s))
    return (run.info)
}


#' Concatenate with newline
#'
#' A simple wrapper for \code{\link{cat}} function that appends newline to output.
#' @param ... arguments to be passed to \code{cat} function
#' @return None (invisible \code{NULL}).
#' @export
catn <- function(...){
    cat(..., "\n")
}


#' Vectorised String Replacement
#'
#' A simple wrapper for \code{\link{gsub}} that replaces all patterns from \code{pattern} argument with ones in \code{replacement} over vector provided in argument \code{x}.
#' @param pattern see eponymous argument for \code{\link{gsub}} function
#' @param replacement see eponymous argument for \code{\link{gsub}} function
#' @param x see eponymous argument for \code{\link{gsub}} function
#' @param ... additional arguments for \code{\link{gsub}} function
#' @references See original thread for more details \url{https://stackoverflow.com/a/6954308/564164}. Special thanks to user Jean-Robert for this one!
#' @return a character vector with string replacements
#' @export
vgsub <- function(pattern, replacement, x, ...){
    for(i in 1:length(pattern))
        x <- gsub(pattern[i], replacement[i], x, ...)
    x
}


#' CamelCase
#'
#' Convert character vector to camelcase - capitalise first letter of each word.
#' @param x a character vector to be converted to camelcase
#' @param delim a string containing regular expression word delimiter
#' @param upper a logical value indicating if the first letter of the first word should be capitalised (defaults to \code{FALSE})
#' @param sep a string to separate words
#' @param ... additional arguments to be passed to \code{strsplit}
#' @return a character vector with strings put in camelcase
#' @examples
#'     tocamel("foo.bar")
#'     ## [1] "fooBar"
#'
#'     tocamel("foo.bar", upper = TRUE)
#'     ## [1] "FooBar"
#'
#'     tocamel(c("foobar", "foo.bar", "camel_case", "a.b.c.d"))
#'     ## [1] "foobar"    "fooBar"    "camelCase" "aBCD"
#' @export
tocamel <- function(x, delim = '[^[:alnum:]]', upper = FALSE, sep = '', ...){

    stopifnot(is.character(x))
    stopifnot(is.string(delim))

    s <- strsplit(x, delim, ...)

    ## TODO: first.case = FALSE by default
    sapply(s, function(y){
        if (any(is.na(y))) {
            y
        } else {
            first <- substring(y, 1, 1)
            if (isTRUE(upper))
                first <- toupper(first)
            else
                first[-1] <- toupper(first[-1])
            paste(first, substring(y, 2), sep = '', collapse = sep)
        }
    })
}


#' Capitalise String
#'
#' Capitalises strings in provided character vector
#' @param x a character vector to capitalise
#' @return character vector with capitalised string elements
#' @examples
#' capitalise(c("foo", "bar")) # [1] "Foo" "Bar"
#' @export
capitalise <- function(x){
    stopifnot(is.character(x))
    if (length(x) > 1)
        return(sapply(x, capitalise, USE.NAMES = FALSE))
    if (nchar(x) == 1)
        return(toupper(x))
    s <- strsplit(x, '', fixed = TRUE)
    sapply(s, function(x){
        paste(toupper(x[1]), paste(x[2:length(x)], collapse = ''), collapse = '', sep = '')
    })
}


#' Stop Execution with String Interpolated Messages
#'
#' This helper combines \code{stop} function with \code{sprintf} thus allowing string interpolated messages when execution is halted.
#' @param s a character vector of format strings
#' @param ... values to be interpolated
#' @return a string containing message that follows execution termination
#' @examples \dontrun{
#' stopf("%.3f is not larger than %d and/or smaller than %d", pi, 10, 40)
#' }
#' @export
stopf <- function(s, ...){
    stop(sprintf(s, ...))
}


#' Send Warning with String Interpolated Messages
#'
#' Combines \code{warning} with \code{sprintf} thus allowing string interpolated warnings.
#' @param s a character vector of format strings
#' @param ... values to be interpolated
#' @examples \dontrun{
#' warningf("%.3f is not larger than %d and/or smaller than %d", pi, 10, 40)
#' }
#' @export
warningf <- function(s, ...){
    warning(sprintf(s, ...))
}


#' Send Message with String Interpolated Messages
#'
#' Combines \code{warning} with \code{sprintf} thus allowing string interpolated diagnostic messages.
#' @param s a character vector of format strings
#' @param ... values to be interpolated
#' @examples \dontrun{
#' messagef("%.3f is not larger than %d and/or smaller than %d", pi, 10, 40)
#' }
#' @export
messagef <- function(s, ...){
    message(sprintf(s, ...))
}



#' Empty Value
#'
#' Rails-inspired helper that checks if vector values are "empty", i.e. if it's: \code{NULL}, zero-length, \code{NA}, \code{NaN}, \code{FALSE}, an empty string or \code{0}. Note that unlike its native R \code{is.<something>} sibling functions, \code{is.empty} is vectorised (hence the "values").
#' @param x an object to check its emptiness
#' @param trim trim whitespace? (\code{TRUE} by default)
#' @param ... additional arguments for \code{\link{sapply}}
#' @examples \dontrun{
#' is.empty(NULL)     # [1] TRUE
#' is.empty(c())      # [1] TRUE
#' is.empty(NA)       # [1] TRUE
#' is.empty(NaN)      # [1] TRUE
#' is.empty("")       # [1] TRUE
#' is.empty(0)        # [1] TRUE
#' is.empty(0.00)     # [1] TRUE
#' is.empty("    ")   # [1] TRUE
#' is.empty("foobar") # [1] FALSE
#' is.empty("    ", trim = FALSE)    # [1] FALSE
#' # is.empty is vectorised!
#' all(is.empty(rep("", 10)))        # [1] TRUE
#' all(is.empty(matrix(NA, 10, 10))) # [1] TRUE
#' }
#' @export
is.empty <- function(x, trim = TRUE, ...) {
    if (length(x) <= 1) {
        if (is.null(x))
            return (TRUE)
        if (length(x) == 0)
            return (TRUE)
        if (is.na(x) || is.nan(x))
            return (TRUE)
        if (is.character(x) && nchar(ifelse(trim, trim.space(x), x)) == 0)
            return (TRUE)
        if (is.logical(x) && !isTRUE(x))
            return (TRUE)
        if (is.numeric(x) && x == 0)
            return (TRUE)
        return (FALSE)
    } else
        sapply(x, is.empty, trim = trim, ...)
}
