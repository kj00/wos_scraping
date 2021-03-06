##
source("new_data_manip/9.R")
source("new_analysis/functions.R")

###
library(tidyverse)
library(plm)
library(texreg)
library(lmtest)
library(sandwich)

###
pdata <- plm.data(datagic[1995 < year & year < 2011], indexes = c("bvdid", "year"))
write_csv(pdata, "new_analysis/pdata.csv")

###make formulas
#variable to formulas



#control variables
control_vars <- c("lemp %>% lead(2)", "lfasset %>% lead(2)", "zero_rd_dum", "year", "gic1", "country")

#main variables
main_var_list <- list("ltotal_patent",
                          c("lcoauthor", "ltotal_patent"),
                          c("lnon_copatent", "lcopatent_nonuniv", "lcopatent_univ_involved"),
                          c("lcoauthor", "lnon_copatent", "lcopatent_nonuniv", "lcopatent_univ_involved"),
                          c("ltotal_patent_wcite"),
                          c("lcoauthor_num_cited", "ltotal_patent_wcite"),
                          c("lnon_copatent_wcite", "lnon_univ_copatent_wcite", "luniv_involved_copatent_wcite"),
                          c("lcoauthor_num_cited", "lnon_copatent_wcite", "lnon_univ_copatent_wcite", "luniv_involved_copatent_wcite")
                          )

#list of dummies
dum_list <- lapply(main_var_list, function(x) {
  x %>% str_replace("^l", "") %>% paste0("zero_", ., "_dum")
})

#
main_var_list <- map(seq_along(dum_list), ~ c(main_var_list[.],  dum_list[.]) %>% unlist)
formula_list <- map(main_var_list,~ var2formula("lsale %>%  lead(2)", ., control_vars))



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

#===========================================================================
coef_list <- map(reg_results, "robust_coef")
glance_list <- map(reg_results, ~ c(round(.$rsq, 2), .$num_obs))

#
glance_list %>% as.data.frame %>% transpose() %>% 
  map(~ paste(.x, collapse = ", ")) %>%
  map2(., c("r-squared: ", "number of observations: "),
       ~ paste0(.y, "(", .x, ")")) %>% 
  unlist %>% 
  paste0(., ".",collapse = " ") -> note
#===========================================================================


##custom.coef > omit.coef > reorder.coef
screenreg(coef_list, omit.coef = "year|Inter|gic|country|dum",
          custom.note = note,
          digits = 3)


htmlreg(coef_list, omit.coef = "year|Inter|gic|country|dum",
        reorder.coef = c(1, 4, 5:12, 2:3),
        custom.note = note,
        digits = 3,
        file = "sale_results3_temp.html")

