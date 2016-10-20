###equations
eqk1 <- log(total_patent + 1) ~  log(coauthor_stock + 1)+ log(total_patent_stock + 1) + 
  lag(lrd, 1) + lemp + lfasset+ zero_rd_dum + na_rd_dum + year


eqk2 <- log(total_patent + 1) ~ log(coauthor_stock + 1) + log(non_copatent_stock + 1) + 
  log(copatent_nonuniv_stock + 1) +
  log(copatent_univ_stock + copatent_univ_other_stock + 1) +
  lag(lrd, 1) + lemp + lfasset+ zero_rd_dum + na_rd_dum + year

eqk3 <- log(total_patent + 1) ~  log(coauthor_stock + 1) + log(non_copatent_stock + 1) +
  log(copatent_nonuniv_stock + 1) + log(copatent_univ_stock + 1) +
  log(copatent_univ_other_stock + 1) +
  lag(lrd, 1) + lemp + lfasset+ zero_rd_dum + na_rd_dum + year


###
kp1 <- plm(eqk1, model = "within", pdata) %>% coeftest(., vcov = pvcovHC(.))
kp2 <- plm(eqk2, model = "within", pdata) %>% coeftest(., vcov = pvcovHC(.))
kp3 <- plm(eqk3, model = "within", pdata) %>% coeftest(., vcov = pvcovHC(.))

screenreg(list(kp1, kp2, kp3))


###citation
eqk1cite <- log(total_patent + 1) ~  log(coauthor_num_cited_stock + 1) + log(total_patent_wcite_stock + 1) + 
  lag(lrd, 1) + lemp + lfasset + zero_rd_dum + na_rd_dum + year 


eqk2cite <- log(total_patent + 1) ~ log(coauthor_num_cited_stock + 1) + log(non_copatent_wcite_stock + 1) + 
  log(non_univ_copatent_wcite_stock + 1) +
  log(only_univ_copatent_wcite_stock + univ_other_copatent_wcite_stock + 1) +
  lag(lrd, 1) + lemp + lfasset + zero_rd_dum + na_rd_dum + year

eqk3cite <- log(total_patent + 1) ~ log(coauthor_num_cited_stock + 1) +
  log(non_copatent_wcite_stock + 1) + 
  log(non_univ_copatent_wcite_stock + 1) +
  log(only_univ_copatent_wcite_stock + 1) +
  log(univ_other_copatent_wcite_stock + 1) +
  lag(lrd, 1) + lemp + lfasset+ zero_rd_dum + na_rd_dum + year

#

kpc1 <- plm(eqk1cite, model = "within", pdata) %>% coeftest(., pvcov = vcovHC(.))
kpc2 <- plm(eqk2cite, model = "within", pdata) %>% coeftest(., pvcov = vcovHC(.))
kpc3 <- plm(eqk3cite, model = "within", pdata) %>% coeftest(., pvcov = vcovHC(.))


#
screenreg(list(kp1, kp2, kp3, kpc1, kpc2, kpc3),
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

