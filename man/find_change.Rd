% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/change.R
\name{find_change}
\alias{find_change}
\title{Find Change Over Time}
\usage{
find_change(dt, dim, var, ...)
}
\arguments{
\item{dt}{Dataset}

\item{dim}{Dimension dataset produced by \code{get_grid()}}

\item{var}{Selected dimension ie. \code{dim}, variable from \code{get_grid()}
function}

\item{...}{Other extended arguments}
}
\description{
Find the change over time. It could be change from previous year
or from a specific time period.
}
