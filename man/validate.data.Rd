% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/validate_data.r
\encoding{UTF-8}
\name{validate.data}
\alias{validate.data}
\title{Validate samples in labels, features, and metadata}
\usage{
validate.data(siamcat, verbose = 1)
}
\arguments{
\item{siamcat}{an object of class \link{siamcat-class}}

\item{verbose}{integer, control output: \code{0} for no output at all,
\code{1} for only information about progress and success, \code{2} for
normal level of information and \code{3} for full debug information,
defaults to \code{1}}
}
\value{
an object of class \link{siamcat-class}
}
\description{
This function checks if labels are available for all samples 
in features. Additionally validates metadata, if available.
}
\details{
This function validates the data by checking that labels are
available for all samples in the feature matrix. Furthermore, the number 
of samples per class is checked to ensure a minimum number. If metadata 
is available, the overlap between labels and metadata is checked as well. 

This function is run when a \link{siamcat-class} object is created.
}
\examples{
data(siamcat_example)

# validate.data should be run before completing the pipeline
# since the complete pipeline had been run on siamcat_example, we
# construct a new siamcat object for the example
feat <- orig_feat(siamcat_example)
label <- label(siamcat_example)
siamcat <- siamcat(feat=feat, label=label, validate=FALSE)
siamcat <- validate.data(siamcat, verbose=2)
}
\keyword{SIAMCAT}
\keyword{validate.data}
