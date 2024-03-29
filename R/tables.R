#' Descriptive Statistics
#'
#' Aggregate table of descriptives according to functions provided in \code{fn} argument. This function follows melt/cast approach used in \code{reshape} package. Variable names specified in \code{measure.vars} argument are treated as \code{measure.vars}, while the ones in \code{id.vars} are treated as \code{id.vars} (see \code{\link[reshape]{melt.data.frame}} for details). Other its formal arguments match with corresponding arguments for \code{\link[reshape]{cast}} function. Some post-processing is done after reshaping, in order to get pretty row and column labels.
#' @param measure.vars either a character vector with variable names from \code{data}, a numeric vector, or a \code{data.frame}
#' @param id.vars same rules apply as in \code{measure.vars}, but defaults to \code{NULL}
#' @param fn a list with functions or a character vector with function names
#' @param data a \code{data.frame} holding variables specified in \code{id.vars} and \code{measure.vars}
#' @param na.rm a logical value indicating whether \code{NA} values should be removed
#' @param margins should margins be included?
#' @param total.name a character string with name for "grand" margin (defaults to "Total")
#' @param use.labels use labels instead of variable names in table header (handle with care, especially if you have lengthy labels). Defaults to value specified in \code{rapport.use.labels} option.
#' @return a \code{data.frame} with aggregated data
#' @examples
#' rp.desc("cyl", NULL, c(mean, sd), mtcars)
#' rp.desc("cyl", "am", c(mean, sd), mtcars, margins = TRUE)
#' rp.desc("hp", c("am", "gear"), c("Average" = mean, "Deviation" = sd), mtcars)
#' @export
#' @importFrom plyr each is.formula here ddply
#' @importFrom reshape2 add_margins
rp.desc <- function(measure.vars, id.vars = NULL, fn, data = NULL, na.rm = FALSE, margins = TRUE, total.name = 'Total', use.labels = getOption('rapport.use.labels')) {

    if (!is.character(id.vars) && !is.character(measure.vars)){
        data         <- if (is.null(id.vars)) data.frame(measure.vars) else data.frame(id.vars, measure.vars)
        id.vars      <- if (is.atomic(id.vars) & !is.null(id.vars)) deparse(substitute(id.vars)) else names(id.vars)
        measure.vars <- if (is.atomic(measure.vars)) deparse(substitute(measure.vars)) else names(measure.vars)
        names(data)  <- c(id.vars, measure.vars)
    }

    ## get function names
    if (is.list(fn)){

        fn.subs <- sapply(substitute(fn), deparse)[-1] # get function names
        fn.nms  <- names(fn)            # get names of function list
        fn.ind  <- names(fn.subs) == '' # get indices of non-named elems

        ## fun list has no named elements, use deparsed/substituted ones
        if (!length(fn.nms)){
            fn.nms <- names(fn) <- fn.subs
        } else {
            ## some function names found...
            if (any(fn.ind)){
                ## ...some missing, replace them with deparsed/substituted ones
                names(fn.subs)[fn.ind] <- fn.subs[fn.ind]
                names(fn) <- names(fn.subs)
            } else {
                names(fn) <- fn.nms     # ...no missing elems, use names
            }
        }
    } else if (is.character(fn)) {
        fn.nms <- fn
    } else if (is.function(fn)){
        fn.nms <- deparse(substitute(fn))
    } else {
        stop('unknown function provided in "fn"')
    }

    ## some shorthands
    n.measure <- length(measure.vars)
    n.id <- length(id.vars)

    ## no factors
    if (is.null(id.vars)) {
        res <- data[, measure.vars]
        if (na.rm)
            res <- na.omit(res)
        res <- sapply(fn.nms, function(x) get(x)(res))
        return(res)
    }

    res <- data[, c(id.vars, measure.vars)]
    if (na.rm)
        res <- na.omit(res)

    ## reshape magic happens here
    if (margins)
        res <- add_margins(res, vars = id.vars)
    res <- ddply(res, id.vars, here(with), each(fn)(get(measure.vars)))
    names(res) <- c(id.vars, names(fn))

    ## use labels for id.vars?
    if (use.labels)
        names(res)[1:n.id] <- label(data[id.vars])

    ## update (all)
    res[, 1:length(id.vars)] <- apply(res[, 1:length(id.vars), drop = FALSE], 2, sub, pattern = '^\\(all\\)$', replacement = total.name)

    ## return
    rownames(res) <- NULL
    class(res) <- c('rp.table', 'data.frame')
    return(res)
}


#' Frequency Table
#'
#' Display frequency table with counts, percentage, and cumulatives.
#' @param f.vars a character vector with variable names
#' @param data a \code{data.frame}
#' @param na.rm should missing values be removed?
#' @param include.na should missing values be included in frequency table?
#' @param drop.unused.levels should empty level combinations be left out
#' @param count show frequencies?
#' @param pct show percentage?
#' @param cumul.count show cumulative frequencies?
#' @param cumul.pct show cumulative percentage?
#' @param total.name a sting containing footer label (defaults to "Total")
#' @param reorder reorder the table based on frequencies?
#' @return a \code{data.frame} with a frequency table
#' @examples \dontrun{
#' rp.freq(c("am", "cyl", "vs"), mtcars)
#' }
#' @export
#' @importFrom reshape2 melt
#' @importFrom stats xtabs na.pass complete.cases
#' @importFrom utils tail
rp.freq <- freq <- function(f.vars, data, na.rm = TRUE, include.na = FALSE, drop.unused.levels = FALSE, count = TRUE, pct = TRUE, cumul.count = TRUE, cumul.pct = TRUE, total.name = 'Total', reorder = FALSE){

    ## R CMD check NOTE dismiss based on http://stackoverflow.com/a/8096882/564164
    N <- `%` <- NULL

    ## TODO: add variables/data.frames instead of names
    exclude <- if (isTRUE(na.rm)) NA else NULL

    tbl <- xtabs(fml('', f.vars), data = data, exclude = exclude, na.action = na.pass)
    tbl <- melt(tbl)
    names(tbl)[ncol(tbl)] <- 'N'        # rename frequency column
    nfac <- length(f.vars)              # number of factors

    if (drop.unused.levels)  tbl <- tbl[tbl$N != 0, ] # remove 0-count levels

    if (reorder)
        tbl <- tbl[order(tbl$N), ]

    ## calculate freqs
    tbl <- transform(tbl, `%` = N / base::sum(N) * 100, check.names = FALSE) # add percentage
    tbl <- transform(tbl, `Cumul. N` = cumsum(N), `Cumul. %` = cumsum(`%`), check.names = FALSE) # add cumulatives

    ## NAs not removed
    if (na.rm == FALSE){
        if (include.na == FALSE){
            cc <- complete.cases(tbl)
            tbl <- tbl[cc, ]
        }
        ## TODO: add Valid/Missing
    }

    ## calculate total
    freqs  <- colSums(tbl[, nfac + 1:2])              # frequency and percent totals
    cumuls <- tail(as.numeric(tail(tbl, 1)), 2)       # cumulative totals
    total  <- c(rep(NA, nfac), freqs, cumuls) # grand total
    rownames(tbl) <- NULL                             # reset row names (important for ascii/HTML export)
    tbl[1:nfac] <- lapply(tbl[1:nfac], as.character)  # "fix" factors
    tbl <- rbind(tbl, total)                          # update table contents
    tbl[nrow(tbl), 1:nfac] <- rep(total.name, nfac)   # add total names

    ## summary stats
    keep <- sapply(list(count, pct, cumul.count, cumul.pct), isTRUE)
    if (all(keep == FALSE))
        stop('no summary to show') # no summary selected
    keep <- c(rep(TRUE, length(f.vars)), keep)          # which columns to keep?
    tbl <- tbl[keep]

    class(tbl) <- c('rp.table', 'data.frame')
    return(tbl)
}
