% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/io.R
\name{ezRead.table}
\alias{ezRead.table}
\title{Modified version of read.table}
\usage{
ezRead.table(file, header = TRUE, sep = "\\t", as.is = TRUE,
  row.names = 1, quote = "", skip = 0, comment.char = "",
  check.names = FALSE, ...)
}
\arguments{
\item{file}{the name of the file to read the data from.}

\item{...}{additional arguments to be passed to \code{read.table()}.}
}
\value{
Returns a data.frame.
}
\description{
Modified version of \code{read.table()} with a different default.
}
\examples{
m1 = ezMatrix(1:20, rows=1:5, cols=1:4)
ezWrite.table(m1, "exampleTable")
ezRead.table("exampleTable")
}
\seealso{
\code{\link[utils]{read.table}}
}
\author{
Rehrauer, Hubert

Schmid, Peter
}
