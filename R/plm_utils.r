#!/usr/bin/Rscript
### SIAMCAT - Statistical Inference of Associations between
### Microbial Communities And host phenoTypes R flavor EMBL
### Heidelberg 2012-2018 GNU GPL 3.0

##### Internal function to train a model for a single CV fold
#' @keywords internal
train.plm <-
    function(data,
        method = c("lasso",
            "enet",
            "ridge",
            "lasso_ll",
            "ridge_ll",
            "randomForest"),
        measure = list("acc"),
        min.nonzero.coeff = 5,
        param.set = NULL,
        neg.lab,
        verbose = 1) {
        ## 1) Define the task Specify the type of analysis (e.g. classification)
        ## and provide data and response variable assert that the label for the
        ## first patient is always the same in order for lasso_ll to work
        ## correctly
        if (data$label[1] != neg.lab) {
            data <- data[c(which(data$label == neg.lab)[1],
                c(seq_len(nrow(data)))[-which(data$label == neg.lab)[1]]), ]
        }
        task <- makeClassifTask(data = data, target = "label")

        ## 2) Define the learner Choose a specific algorithm (e.g. linear
        # discriminant analysis)
        cost <- 10 ^ seq(-2, 3, length = 6 + 5 + 10)

        ### the most common learner defined here to remove redundancy
        cl <- "classif.cvglmnet"
        parameters <-
            get.parameters.from.param.set(param.set = param.set,
                method = method, sqrt(nrow(data)))

        if (method == "lasso") {
            lrn <-
                makeLearner(
                    cl,
                    predict.type = "prob",
                    nlambda = 100,
                    alpha = 1
                )
        } else if (method == "ridge") {
            lrn <-
                makeLearner(
                    cl,
                    predict.type = "prob",
                    nlambda = 100,
                    alpha = 0
                )
        } else if (method == "enet") {
            if ('alpha' %in% names(parameters)){
                lrn <- makeLearner(cl, predict.type = 'prob',
                    nlambda=10, alpha=parameters$alpha)
                parameters <- NULL
            } else if ('pars' %in% names(parameters)){
                lrn <- makeLearner(cl, predict.type = "prob",
                    nlambda = 10, alpha=parameters$pars$alpha)
                parameters <- NULL
            } else {
                lrn <- makeLearner(cl, predict.type = "prob", nlambda = 10)
            }
        } else if (method == "lasso_ll") {
            cl <- "classif.LiblineaRL1LogReg"
            lrn <-
                makeLearner(cl,
                    predict.type = "prob",
                    epsilon = 1e-08,
                    wi = parameters$class.weights)
            parameters <- parameters$cost
        } else if (method == "ridge_ll") {
            cl <- "classif.LiblineaRL2LogReg"
            lrn <-
                makeLearner(
                    cl,
                    predict.type = "prob",
                    epsilon = 1e-08,
                    type = 0,
                    wi = parameters$class.weights)
            parameters <- parameters$cost
        } else if (method == "randomForest") {
            cl <- "classif.randomForest"
            lrn <- makeLearner(cl,
                predict.type = "prob",
                fix.factors.prediction = TRUE)

        } else {
            stop(
                method,
                " is not a valid method, currently supported: lasso,
                enet, ridge, lasso_ll, ridge_ll, randomForest.\n"
            )
        }
        show.info <- FALSE
        if (verbose > 2)
            show.info <- TRUE

        ## 3) Fit the model Train the learner on the task using a random subset
        ##of the data as training set
        if (!all(is.null(parameters))) {
            hyperPars <- tuneParams(
                learner = lrn,
                task = task,
                resampling = makeResampleDesc("CV", iters = 5L,
                                                stratify = TRUE),
                par.set = parameters,
                control = makeTuneControlGrid(resolution = 10L),
                measures = measure,
                show.info = show.info
            )
            lrn <- setHyperPars(lrn, par.vals = hyperPars$x)
        }
        model <- train(lrn, task)

        if (cl == "classif.cvglmnet") {
            opt.lambda <- get.optimal.lambda.for.glmnet(model, task, measure,
                min.nonzero.coeff)
            # transform model
            if (is.null(model$learner$par.vals$s)) {
                model$learner.model$lambda.1se <- opt.lambda
            } else {
                model$learner.model[[model$learner$par.vals$s]] <- opt.lambda
            }
            coef <- coefficients(model$learner.model)
            bias.idx <- which(rownames(coef) == "(Intercept)")
            coef <- coef[-bias.idx, ]
            model$feat.weights <-
                (-1) * as.numeric(coef)  ### check!!!
            model$learner.model$call <- NULL
        } else if (cl == "classif.LiblineaRL1LogReg") {
            model$feat.weights <-
                model$learner.model$W[
                    -which(colnames(model$learner.model$W) == "Bias")]
        } else if (cl == "classif.randomForest") {
            model$feat.weights <- model$learner.model$importance
        }
        model$task <- task

        return(model)
    }

#' @keywords internal
get.optimal.lambda.for.glmnet <-
    function(trained.model,
        training.task,
        perf.measure,
        min.nonzero.coeff) {
        # get lambdas that fullfill the minimum nonzero coefficients criterion
        lambdas <-
            trained.model$learner.model$glmnet.fit$lambda[
                which(trained.model$learner.model$nzero >= min.nonzero.coeff)]
        # get performance on training set for all those lambdas in trace
        performances <-
            vapply(
                lambdas,
                FUN = function(lambda, model, task,
                    measure) {
                    model.transformed <- model
                    if (is.null(model.transformed$learner$par.vals$s)) {
                        model.transformed$learner.model$lambda.1se <- lambda
                    } else {
                        model.transformed$learner.model[[
                            model.transformed$learner$par.vals$s]] <-
                            lambda
                    }
                    pred.temp <- predict(model.transformed, task)
                    performance(pred.temp, measures = measure)
                },
                model = trained.model,
                task = training.task,
                measure = perf.measure,
                USE.NAMES = FALSE,
                FUN.VALUE = double(1)
            )
        # get optimal lambda in depence of the performance measure
        if (length(perf.measure) == 1) {
            if (perf.measure[[1]]$minimize == TRUE) {
                opt.lambda <- lambdas[which(performances ==
                        min(performances))[1]]
            } else {
                opt.lambda <- lambdas[which(performances ==
                        max(performances))[1]]
            }
        } else {
            opt.idx <- c()
            for (m in seq_along(perf.measure)) {
                if (perf.measure[[m]]$minimize == TRUE) {
                    opt.idx <- c(opt.idx, which(performances[m, ] ==
                            min(performances[m, ]))[1])
                } else {
                    opt.idx <- c(opt.idx, which(performances[m, ] ==
                            max(performances[m, ]))[1])
                }
            }
            opt.lambda <- lambdas[floor(mean(opt.idx))]
        }
        return(opt.lambda)
    }

#' @keywords internal
get.parameters.from.param.set <-
    function(param.set, method, sqrt.mdim) {
        cost <- 10 ^ seq(-2, 3, length = 6 + 5 + 10)
        ntree <- c(100, 1000)
        mtry <-
            c(round(sqrt.mdim / 2), round(sqrt.mdim), round(sqrt.mdim * 2))
        alpha <- c(0, 1)
        class.weights <- c(5, 1)
        names(class.weights) <- c(-1, 1)
        parameters <- NULL
        if (method == "lasso_ll") {
            if (!all(is.null(param.set))) {
                if ("cost" %in% names(param.set))
                    cost <- param.set$cost
                if ("class.weights" %in% names(param.set)){
                    class.weights <- param.set$class.weights
                    names(class.weights) <- c(-1, 1)
                }
            }
            parameters <- list("class.weights"=class.weights,
                'cost'=makeParamSet(makeDiscreteParam("cost", values = cost)))
        } else if (method == "randomForest") {
            if (!all(is.null(param.set))) {
                if ("ntree" %in% names(param.set))
                    ntree <- param.set$ntree
                if ("mtry" %in% names(param.set))
                    mtry <- param.set$mtry
            }
            parameters <-
                makeParamSet(
                    makeNumericParam("ntree", lower = ntree[1],
                        upper = ntree[2]),
                    makeDiscreteParam("mtry",
                        values = mtry)
                )
        } else if (method == "enet") {
            if (!all(is.null(param.set))) {
                if ("alpha" %in% names(param.set))
                    alpha <- param.set$alpha
            }
            if (length(alpha)==1){
                parameters <- list(alpha=alpha)
            } else if (length(alpha) == 2){
                parameters <-
                    makeParamSet(makeNumericParam("alpha", lower = alpha[1],
                        upper = alpha[2]))
            } else {
                stop("'alpha' parameter can not have more than two entries!")
            }
        }
        return(parameters)
}
