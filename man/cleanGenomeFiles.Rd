% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ngsReferenceFiles.r
\name{cleanGenomeFiles}
\alias{cleanGenomeFiles}
\title{Cleans genome files}
\usage{
cleanGenomeFiles(genomeFile, genesFile, patchPattern = "PATCH")
}
\arguments{
\item{genomeFile}{a character specifying the path to a fasta file.}

\item{genesFile}{a character specifying the path to a gtf file.}

\item{patchPattern}{a character specifying the pattern of patches to remove from the genome.}
}
\value{
Returns a list containing a fasta and a gtf object.
}
\description{
Removes from the seqence files all descriptionso in the header line.
RemovesCleans the fasta and gtf files before they get written into the folder structure.
}
\examples{
gtf = system.file("extdata/genes.gtf", package="ezRun", mustWork=TRUE)
fasta = system.file("extdata/genome.fa", package="ezRun", mustWork=TRUE)
cg = cleanGenomeFiles(fasta, gtf)
}
\author{
Rehrauer, Hubert

Schmid, Peter
}
