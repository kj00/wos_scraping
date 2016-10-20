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
datagic[, rd2fasset := rd/fasset]
pdata <- plm.data(datagic[1988 < year & year < 2016], indexes = c("bvdid", "year"))


write_csv(pdata, "new_analysis/pdata.csv")

###equations
var2formula <- function(dependent_var, main_formula, control) {
  paste0(control, collapse = " + ") %>% 
    paste0(main_formula, "+", ., collapse = "+") %>% 
    paste0(dependent_var, " ~ ", .) %>% 
    as.formula()
}

control_vars <- c("sale", "rd2fasset", "zero_rd_dum", "year", "gic1", "country")



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

main_var_list<- lapply(1:length(dum_list), function(i) { c(main_var_list[i],  dum_list[i]) %>% unlist })


formula_list <- lapply(main_var_list, function(x) {var2formula("ltobin", x, control_vars)})




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
              plm(i, model = "pooling" , pdata) %>% coeftest(., vcov = pvcovHC(.))#,
              #plm(i, model = "within", pdata) %>% coeftest(., vcov = pvcovHC(.)),
              #pggls(i, model = "within", pdata) %>% coeftest()
            )
          }


stopCluster(cl)

reg_results %<>% unlist(recursive = F)

###
#screenreg(reg_results, omit.coef = "year|Intercept|country|gic")
htmlreg(reg_results, omit.coef = "year|Inter|country|gic|dum",
        reorder.coef = c(1, 4,5:9, 10:12,   2:3),
        file = "tobin_results_temp.doc")


