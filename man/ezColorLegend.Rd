% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots.R
\name{ezColorLegend}
\alias{ezColorLegend}
\title{Plots a color scale}
\usage{
ezColorLegend(colorRange = c(-3, 3), colors = getBlueRedScale(),
  vertical = TRUE, at = seq(from = colorRange[1], to = colorRange[2], by =
  by.label), labels = as.character(at), by.label = 0.5)
}
\arguments{
\item{colorRange}{two numerics specifying the range to plot to the axis.}

\item{colors}{a character vector containing colors.}

\item{vertical}{a logical indicating whether to plot vertically.}

\item{at}{a numeric vector specifying where to put axis ticks.}

\item{labels}{a character vector specifying the axis labels.}

\item{by.label}{a numeric specifying the interval between axis labels.}
}
\description{
Plots a color scale with colors derived from \code{getBlueRedScale()}.
}
\examples{
ezColorLegend()
}
\author{
Rehrauer, Hubert

Schmid, Peter
}
