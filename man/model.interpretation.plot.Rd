% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_interpretation_plot.R
\encoding{UTF-8}
\name{model.interpretation.plot}
\alias{model.interpretation.plot}
\title{Model Interpretation Plot}
\usage{
model.interpretation.plot(siamcat, fn.plot = NULL,
color.scheme = "BrBG", consens.thres = 0.5, heatmap.type = "zscore",
limits = c(-3, 3), log.n0 = 1e-06, max.show = 50, prompt=TRUE,
verbose = 1)
}
\arguments{
\item{siamcat}{object of class \link{siamcat-class}}

\item{fn.plot}{string, filename for the pdf-plot}

\item{color.scheme}{color scheme for the heatmap, defaults to \code{'BrBG'}}

\item{consens.thres}{float, minimal ratio of models incorporating a feature
in order to include it into the heatmap, defaults to \code{0.5}
\strong{Note that for \code{'randomForest'} models, this cutoff specifies the
minimum median Gini coefficient for a feature to be included and
should therefore be much lower, e.g. \code{0.01}}}

\item{heatmap.type}{string, type of the heatmap, can be either \code{'fc'}
or \code{'zscore'}, defaults to \code{'zscore'}}

\item{limits}{vector, cutoff for extreme values in the heatmap,
defaults to \code{c(-3, 3)}}

\item{log.n0}{float, pseudocount to be added before log-transformation
of features, defaults to \code{1e-06}}

\item{max.show}{integer, maximum number of features to be shown in the model
interpretation plot, defaults to 50}

\item{prompt}{boolean, turn on/off prompting user input when not plotting
into a pdf-file, defaults to TRUE}

\item{verbose}{control output: \code{0} for no output at all, \code{1}
for only information about progress and success, \code{2} for normal
level of information and \code{3} for full debug information,
defaults to \code{1}}
}
\value{
Does not return anything, but produces the model interpretation plot.
}
\description{
This function produces a plot for model interpretation
}
\details{
Produces a plot consisting of \itemize{
\item a barplot showing the feature weights and their robustness (i.e. in
what proportion of models have they been incorporated)
\item a heatmap showing the z-scores of the metagenomic features across
samples
\item another heatmap displaying the metadata categories (if applicable)
\item a boxplot displaying the poportion of weight per model that is
actually shown for the features that are incorporated into more than
\code{consens.thres} percent of the models.
}
}
\examples{
data(siamcat_example)

# simple working example
siamcat_example <- train.model(siamcat_example, method='lasso')
model.interpretation.plot(siamcat_example, fn.plot='./interpretion.pdf',
    heatmap.type='zscore')
}
\keyword{SIAMCAT}
\keyword{model.interpretation.plot}
