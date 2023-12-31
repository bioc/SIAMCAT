% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evaluate_predictions.r
\encoding{UTF-8}
\name{evaluate.predictions}
\alias{evaluate.predictions}
\title{Evaluate prediction results}
\usage{
evaluate.predictions(siamcat, verbose = 1)
}
\arguments{
\item{siamcat}{object of class \link{siamcat-class}}

\item{verbose}{integer, control output: \code{0} for no output at all, 
\code{1} for only information about progress and success, \code{2} for 
normal level of information and \code{3} for full debug information,
defaults to \code{1}}
}
\value{
object of class \link{siamcat-class} with the slot 
\code{eval_data} filled
}
\description{
This function compares the predictions (from 
[make.predictions]) and true labels for all samples and evaluates 
the results.
}
\section{Binary classification problems}{

This function calculates several metrics for the predictions in 
the \code{pred_matrix}-slot of the \link{siamcat-class}-object. 
The Area Under the Receiver Operating Characteristic (ROC) Curve (AU-ROC) 
and the Precision-Recall Curve will be evaluated and the results will be 
saved in the \code{eval_data}-slot of the supplied \link{siamcat-class}-
object. The \code{eval_data}-slot contains a list with several entries: 
\itemize{
\item \code{$roc} - average ROC-curve across repeats or a single ROC-curve 
on complete dataset (see \link[pROC]{roc});
\item \code{$auroc} - AUC value for the average ROC-curve;
\item \code{$prc} - list containing the positive predictive value 
(precision) and true positive rate (recall) values used to plot the mean 
PR curve;
\item \code{$auprc} - AUC value for the mean PR curve;
\item \code{$ev} - list containing for different decision thresholds the 
number of false positives, false negatives, true negatives, and true 
positives.}
For the case of repeated cross-validation, the function will additionally 
return \itemize{
\item \code{$roc.all} - list of roc objects (see \link[pROC]{roc}) 
for every repeat;
\item \code{$auroc.all} - vector of AUC values for the ROC curves 
for every repeat;
\item \code{$prc.all} - list of PR curves for every repeat;
\item \code{$auprc.all} - vector of AUC values for the PR curves 
for every repeat;
\item \code{$ev.all} - list of \code{ev} lists (see above) 
for every repeat.}
}

\section{Regression problems}{

This function calculates several metrics for the evaluation of predictions
and will store the results in the \code{eval_data}-slot of the supplied 
\link{siamcat-class} objects. The \code{eval_data}-slot will contain:
\itemize{
\item \code{r2} - the mean R squared value across repeats or a single 
R-squared value on the complete dataset;
\item \code{mae} - them mean absolute error of the predictions;
\item \code{mse} - the mean squared error of the predictions.}
For the case of repeated cross-validation, the function will additionally 
compute all three of these measures for the individual cross-validation 
repeats and will store the results in the \code{eval_data} slot as 
\code{r2.all}, \code{mae.all}, and \code{mse.all}.
}

\examples{
data(siamcat_example)

siamcat_evaluated <- evaluate.predictions(siamcat_example)
}
\keyword{SIAMCAT}
\keyword{evaluate.predictions}
