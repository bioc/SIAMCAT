% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/siamcat_class_accessors.R
\name{accessSlot}
\alias{accessSlot}
\title{Universal slot accessor function for siamcat-class.}
\usage{
accessSlot(siamcat, slot, verbose=1)
}
\arguments{
\item{siamcat}{an object of \link{siamcat-class}.}

\item{slot}{A character string indicating the slot (not data class)
of the component data type that is desired.}

\item{verbose}{If the slot is empty, should a message be printed? values
can be either 0 (no output) or 1 (print message)}
}
\value{
Returns the component object specified by the argument \code{slot}.
    Returns NULL if slot does not exist.
}
\description{
This function is used internally by many accessors.
}
\examples{
#
data(siamcat_example)
accessSlot(siamcat_example, "label")
accessSlot(siamcat_example, "model_list")
}
\keyword{internal}
