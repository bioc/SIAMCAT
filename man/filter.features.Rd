% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_features.r
\encoding{UTF-8}
\name{filter.features}
\alias{filter.features}
\title{Perform unsupervised feature filtering.}
\usage{
filter.features(siamcat, filter.method = "abundance", 
cutoff = 0.001, rm.unmapped = TRUE, feature.type='original', verbose = 1)
}
\arguments{
\item{siamcat}{an object of class \link{siamcat-class}}

\item{filter.method}{string, method used for filtering the features, can be
one of these: \code{c('abundance', 'cum.abundance', 'prevalence',
'variance', 'pass')}, defaults to \code{'abundance'}}

\item{cutoff}{float, abundace, prevalence, or variance cutoff, defaults
to \code{0.001} (see Details below)}

\item{rm.unmapped}{boolean, should unmapped reads be discarded?, defaults to
\code{TRUE}}

\item{feature.type}{string, on which type of features should the function
work? Can be either \code{"original"}, \code{"filtered"}, or
\code{"normalized"}. Please only change this paramter if you know what
you are doing!}

\item{verbose}{integer, control output: \code{0} for no output at all,
\code{1} for only information about progress and success, \code{2} for
normal level of information and \code{3} for full debug information,
defaults to \code{1}}
}
\value{
siamcat an object of class \link{siamcat-class}
}
\description{
This function performs unsupervised feature filtering.
}
\details{
This function filters the features in a \link{siamcat-class}
object in a unsupervised manner.

The different filter methods work in the following way: \itemize{
\item \code{'abundace'} - remove features whose maximum abundance is
never above the threshold value in any of the samples
\item \code{'cum.abundance'} - remove features with very low abundance
in all samples, i.e. those that are never among the most abundant
entities that collectively make up (1-cutoff) of the reads in
any sample
\item \code{'prevalence'} - remove features with low prevalence across
samples, i.e. those that are undetected (relative abundance of 0)
in more than \code{1 - cutoff} percent of samples.
\item \code{'variance'} - remove features with low variance across
samples, i.e. those that have a variance lower than \code{cutoff}
\item \code{'pass'} - pass-through filtering will not change the
features
}

Features can also be filtered repeatedly with different methods, e.g.
first using the maximum abundance filtering and then using prevalence
filtering.
However, if a filtering method has already been applied to the dataset, 
SIAMCAT will default back on the original features for filtering.
}
\examples{
# Example dataset
data(siamcat_example)

# Simple examples
siamcat_filtered <- filter.features(siamcat_example,
    filter.method='abundance',
    cutoff=1e-03)

# 5\% prevalence filtering
siamcat_filtered <- filter.features(siamcat_example,
    filter.method='prevalence',
    cutoff=0.05)

# filter first for abundance and then for prevalence
siamcat_filt <- filter.features(siamcat_example, 
    filter.method='abundance', cutoff=1e-03)
siamcat_filt <- filter.features(siamcat_filt, filter.method='prevalence', 
    cutoff=0.05, feature.type='filtered')
}
\keyword{SIAMCAT}
\keyword{filter.features}
