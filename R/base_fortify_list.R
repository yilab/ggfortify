#' Convert list to data.frame
#'
#' @param model \code{list} instance
#' @inheritParams fortify_base
#' @return data.frame
#' @export
fortify.list <- function(model, data = NULL, ...) {
  klass <- infer(model)
  if (klass == 'mds-like') {
    return(ggplot2::fortify(model$points))
  } else if (klass == 'dlmSmooth') {
    s <- dlm::dropFirst(model$s)
    if (!is.univariate(s, raise = FALSE)) {
      s <- s[, 1]
    }
    return(ggplot2::fortify(s))
  } else if (klass == 'KFASSignal') {
    return(ggplot2::fortify(model$signal))
  }
  stop('Unable to infer class from input list')
}

#' Autoplot list
#'
#' @param object \code{list} instance
#' @param ... other arguments passed to methods
#' @return ggplot
#' @export
autoplot.list <- function(object, ...) {
  klass <- infer(object)
  if (klass == 'mds-like') {
    return(ggplot2::autoplot(object$points[, 1:2], geom = 'point', ...))
  } else if (klass == 'dlmSmooth') {
    s <- dlm::dropFirst(object$s)
    if (!is.univariate(s, raise = FALSE)) {
      s <- s[, 1]
    }
    return(ggplot2::autoplot(s, ...))
  } else if (klass == 'KFASSignal') {
    return(ggplot2::autoplot(object$signal, ...))
  }
  stop('Unable to infer class from input list')
}

#' Infer class name
#'
#' @param data list instance
#' @return character
#' @export
infer <- function(data) {
  if (check_names(data, c('points', 'eig', 'x', 'ac', 'GOF'))) {
    # cmdscale
    return('mds-like')
  } else if (check_names(data, c('points', 'stress'))) {
    # isoMDS
    return('mds-like')
  } else if (check_names(data, c('points', 'stress', 'call'))) {
    # sammon
    return('mds-like')
  } else if (check_names(data, c('s', 'U.S', 'D.S'))) {
    # dlm::dlmSmooth
    return('dlmSmooth')
  } else if (check_names(data, c('signal', 'variance'))) {
      # KFAS::signal
      return('KFASSignal')
  }
  stop('Unable to infer class from input list')
}

#' Check data names are equal with expected
#'
#' @param data \code{list} instance to be checked
#' @param expected expected character vector
#' @return logical
check_names <- function(data, expected) {
  n <- names(data)
  if (length(n) == length(expected) && all(n == expected)) {
    return(TRUE)
  }
  return (FALSE)
}

