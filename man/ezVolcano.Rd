% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots.R
\name{ezVolcano}
\alias{ezVolcano}
\title{Does a volcano plot}
\usage{
ezVolcano(log2Ratio, pValue, yType = "p-value", xlim = NULL, ylim = NULL,
  isPresent = NULL, types = NULL, pch = 16,
  colors = rainbow(ncol(types)), legendPos = "bottomright", cex.main = 1,
  cex = 1, ...)
}
\arguments{
\item{log2Ratio}{a numeric vector containing the log2 ratios of a result.}

\item{pValue}{a numeric vector containing the p-Values of a result.}

\item{yType}{a character specifying the type of the y-value. Gets pasted onto the y-axis of the plot.}

\item{xlim}{integers specifying the x limits of the plot.}

\item{ylim}{integers specifying the y limits of the plot.}

\item{isPresent}{a logical specifying whether the signal is present.}

\item{types}{a character vector containing the types.}

\item{pch}{an integer specifying the look of plotted points.}

\item{colors}{a character vector containing colors.}

\item{legendPos}{a character vector or integer specifying the position of the legend.}

\item{cex.main}{a numeric specifying the size of main titles relative to \code{cex}.}

\item{cex}{a numeric specifying the size of text and symbols.}

\item{...}{additional arguments to be passed further.}
}
\description{
Does a volcano plot.
}
\examples{
types = data.frame(matrix(rep(1:10, each=10), 10))
ezVolcano(log2Ratio=1:100, pValue=rep(10^(-4:5), each=10),
pch=16, isPresent=1:50, types=types, colors=rainbow(ncol(types)), legendPos="bottomleft")
}
\author{
Rehrauer, Hubert

Schmid, Peter
}
