#' Coerce lists and matrices to correlation data frames
#'
#' A wrapper function to coerce objects in a valid format (such as correlation
#' matrices created using the base function, \code{\link[stats]{cor}}) into a
#' correlation data frame.
#'
#' @param x A list, data frame or matrix that can be coerced into a correlation
#'   data frame.
#' @param diagonal Value (typically numeric or NA) to set the diagonal to
#' @return A correlation data frame
#' @export
#' @examples
#' x <- cor(mtcars)
#' as_cordf(x)
#' as_cordf(x, diagonal = 1)
as_cordf <- function(x, diagonal = NA) {
  if (inherits(x, "cor_df")) {
    rlang::warn("x is already a correlation data frame.")
    return(x)
  }
  x <- as.data.frame(x)
  row_name <- x$term
  x <- x[colnames(x) != "term"]
  rownames(x) <- row_name
  if (ncol(x) != nrow(x)) {
    rlang::abort(
      "Input object x is not a square. ",
      "The number of columns must be equal to the number of rows."
    )
  }
  if (ncol(x) > 1) diag(x) <- diagonal
  new_cordf(x, names(x))
}

new_cordf <- function(x, term = NULL) {
  if (!is.null(term)) {
    x <- first_col(x, term)
  }
  class(x) <- c("cor_df", class(x))
  x
}

#' Add a first column to a data.frame
#'
#' Add a first column to a data.frame. This is most commonly used to append a
#' term column to create a cor_df.
#'
#' @param df Data frame
#' @param ... Values to go into the column
#' @param var Label for the column, with the default "term"
#' @export
#' @examples
#' first_col(mtcars, 1:nrow(mtcars))
first_col <- function(df, ..., var = "term") {
  stopifnot(is.data.frame(df))

  if (tibble::has_name(df, var)) {
    rlang::abort(paste("There is a column named ", var, " already!"))
  }

  new_col <- tibble::tibble(...)
  names(new_col) <- var
  new_df <- c(new_col, df)
  dplyr::as_tibble(new_df)
}

#' Number of pairwise complete cases.
#'
#' Compute the number of complete cases in a pairwise fashion for \code{x} (and
#' \code{y}).
#'
#' @inheritParams stats::cor
#' @return Matrix of pairwise sample sizes (number of complete cases).
#' @export
#' @examples
#' pair_n(mtcars)
pair_n <- function(x, y = NULL) {
  if (is.null(y)) y <- x
  x <- t(!is.na(x)) %*% (!is.na(y))
  class(x) <- c("n_mat", "matrix")
  x
}

#' Convert a correlation data frame to matrix format
#'
#' Convert a correlation data frame to original matrix format.
#'
#' @param x A correlation data frame. See \code{\link{correlate}} or \code{\link{as_cordf}}.
#' @inheritParams as_cordf
#' @return Correlation matrix
#' @export
#' @examples
#' x <- correlate(mtcars)
#' as_matrix(x)
as_matrix <- function(x, diagonal) {
  UseMethod("as_matrix")
}
