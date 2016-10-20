source("new_data_manip/9.R")
source("analysis/func.R")

###
library(plm)
library(pglm)
library(mgcv)
library(texreg)
library(lmtest)
library(sandwich)

###
pdata <- plm.data(datagic[1988 < year & year < 2016], indexes = c("bvdid", "year"))
write_csv(pdata, "new_analysis/pdata.csv")

###equations
var2formula <- function(dependent_var, main_vars, control, dum = F) {
  
  paste0(c(main_vars, control), collapse = " + ") %>% 
    paste0(dependent_var, " ~ ", .) %>% 
    as.formula()
  
}

control_vars <- c("lemp %>% lead(2)", "lfasset %>% lead(2)", "zero_rd_dum", "year", "gic1", "country")



main_var_list <- list("ltotal_patent",
                          c("lcoauthor", "ltotal_patent"),
                          c("lnon_copatent", "lcopatent_nonuniv", "lcopatent_univ_involved"),
                          c("lcoauthor", "lnon_copatent", "lcopatent_nonuniv", "lcopatent_univ_involved"),
                          c("ltotal_patent_wcite"),
                          c("lcoauthor_num_cited", "ltotal_patent_wcite"),
                          c("lnon_copatent_wcite", "lnon_univ_copatent_wcite", "luniv_involved_copatent_wcite"),
                          c("lcoauthor_num_cited", "lnon_copatent_wcite", "lnon_univ_copatent_wcite", "luniv_involved_copatent_wcite")
                          )

dum_list <- lapply(main_var_list, function(x) {
  x %>% str_replace("^l", "") %>% paste0("zero_", ., "_dum")
})

main_var_list<- lapply(seq_along(dum_list), function(i) { c(main_var_list[i],  dum_list[i]) %>% unlist })
formula_list <- lapply(main_var_list, function(x) {var2formula("lsale %>%  lead(2)", x, control_vars)})


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

##
mysummary.plm <- function(x) {
list(robust_coef = lmtest::coeftest(x, vcov = plm::pvcovHC(x)),
     rsq = r.squared(x), num_obs = numobs(x))
}

mysummary.pggls <- function(x) {
  list(robust_coef = lmtest::coeftest(x),
       rsq = rsq_pggls(x), num_obs = numobs(x))
}


###
library(foreach)
library(doParallel)

cl <- makeCluster(detectCores())
registerDoParallel(cl)

reg_results <- 
  foreach(i = formula_list,
          .packages = c("magrittr", "plm", "lmtest"),
          .combine = list,
          .multicombine = T) %dopar% {
            list(
              pooled = plm(i, model = "pooling" , pdata) %>% mysummary.plm,
              fe = plm(i, model = "within", pdata) %>% mysummary.plm,
              fe_gls = pggls(i, model = "within", pdata) %>% mysummary.pggls
            )
          }


stopCluster(cl)

###
reg_results %<>% flatten()

#
coef_list <- map(reg_results, ~ .$robust_coef)
glance_list <- map(reg_results, ~ c(round(.$rsq, 2), .$num_obs))

#
glance_list %>% as.data.frame %>% transpose() %>% 
  map(~ paste(.x, collapse = ", ")) %>%
  map2(., c("r-squared: ", "number of observations: "),
       ~ paste0(.y, "(", .x, ")")) %>% 
  unlist %>% 
  paste0(., ".",collapse = " ") -> note



##custom.coef > omit.coef > reorder.coef
screenreg(coef_list, omit.coef = "year|Inter|gic|country|dum",
          custom.note = note,
          digits = 3)


htmlreg(coef_list, omit.coef = "year|Inter|gic|country|dum",
        reorder.coef = c(1, 4, 5:12, 2:3),
        custom.note = note,
        digits = 3,
        file = "sale_results2_temp.doc")




#custom.coef > omit.coef > reorder.coef
screenreg(reg_results,

          custom.coef.names = c("log coauthor + 1", "log total patent + 1",
                                "log R&D inv, t-1", "log employee", "log fixed asset",
                                "zero R&D dummy", "NA R&D dummy",
                                rep(NA, 25),
                               "log single patent + 1",
                               "log non-university copatent + 1",
                               "log university involved copatent + 1",
                               "log copatent university + 1",
                               "log copatent university and other + 1",
                      "log coauthor citation + 1", "log total patent citation + 1",
                      "log single patent citation + 1",
                      "log non-university copatent citaiton + 1",
                      "log university involved copatent citation + 1",
                      "log university copatent copatent citation + 1",
                      "log university and other copatent citation + 1"),
          omit.coef = "year",
          reorder.coef = c(1, 13, 2, 14 ,8:12, 15:19, 3:7),
          custom.note = "Firm level FE and Year effects are included.  N = 14628,  Rsq; 0.51, 0.51, 0.51, 0.53, 0.53, 0.53")


