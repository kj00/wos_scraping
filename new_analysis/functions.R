##
var2formula <- function(dependent_var, main_formula, control) {
  paste0(control, collapse = " + ") %>% 
    paste0(main_formula, "+", ., collapse = "+") %>% 
    paste0(dependent_var, " ~ ", .) %>% 
    as.formula()
}
###
#r-squared for pggls object
rsq_pggls <- function(pggls_model) {
  model <- pggls_model
  class(model) <- c("plm", "panelmodel")
  plm::r.squared(model)
}

#number of observations
numobs <- function(model) {
  model$model[[1]] %>% length
}

##summary function
#
mysummary.plm <- function(x) {
  list(robust_coef = lmtest::coeftest(x, vcov = plm::pvcovHC(x)), ###
       rsq = r.squared(x), num_obs = numobs(x))
}
#
mysummary.pggls <- function(x) {
  list(robust_coef = lmtest::coeftest(x), ###for pggls, pvcovHC cannot be applied.
       rsq = rsq_pggls(x), num_obs = numobs(x))
}
