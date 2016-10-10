source("data_manip/aggregate_data.R")
source("analysis/func.R")
###
library(plm)
library(pglm)
library(mgcv)
library(texreg)
library(lmtest)
library(sandwich

###
pdata <- plm.data(datagic[year < 2015], indexes = c("BvD ID number", "year"))


#datagam<-datagic %>% 
#  na.omit %>% as.data.frame
#datagam$id <- datagam$`BvD ID number`
#colnames(datagam)[8] <- "id"

###equations
base_term <- "lemp + lfasset  + year + zero_rd_dum"

eq_roll_1 <-  lsale ~ lag(log(rollsum_3_copatent + 1), 5) +
  lag(log(rollsum_3_totalpatent - rollsum_3_copatent + 1), 5) +
  lag(log(rollsum_3_coauthor + 1), 5) +
  lag(lrd, 1) +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_2 <-  lsale ~ lag(log(rollsum_3_copatent + 1), 5) + lag(log(rollsum_3_coauthor + 1), 5)+
  lag(lrd, 1) +lemp + lfasset  + year + zero_rd_dum




eq_roll_1 <-  lsale ~ lag(log(rollsum_3_copatent_num_cited + 1), 3) +
  lag(log(rollsum_3_total_num_cited - rollsum_3_copatent_num_cited + 1), 3) +
  lag(log(rollsum_3_coauthor_num_cited + 1), 3) +
  lag(log(rollsum_3_totalpaper_num_cited - rollsum_3_coauthor_num_cited + 1), 3) +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_1 <- lsale ~ log(totalpatent_stock + 1) + 
  lag(log(rollsum_3_copatent + 1), 3) +
  lag(log(rollsum_3_coauthor + 1), 3) +
  lemp + lfasset  + year 

eq_roll_2 <-  lsale ~lag(log(rollsum_3_copatent_num_cited + 1), 3) +
  lag(log(rollsum_3_coauthor_num_cited + 1), 3) + lag(lrd, 1) +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_3 <-  lsale ~lag(log(rollsum_3_copatent + 1), 3) +
  lag(log(rollsum_3_coauthor + 1), 3) +
  lag(log(cumsum_total_num_cited + 1),1)  +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_3 <-  lsale ~lag(log(rollsum_3_copatent + 1), 3) +
    lag(log(rollsum_3_coauthor + 1), 3) +
    lag(log(cumsum_total_num_cited + 1),1) + lag(log(cumsum_totalpaper_num_cited + 1), 1) +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_3 <-  lsale ~lag(log(rollsum_3_copatent + 1), 3) +
  lag(log(cumsum_total_num_cited + 1)) +
  lemp + lfasset  + year + zero_rd_dum

  eq_roll_4 <-  lsale ~lag(log(rollsum_3_copatent + 1), 3) +
    lag(log(rollsum_3_coauthor + 1), 3) +
    lag(log(cumsum_total_num_cited + 1),1) + lag(log(cumsum_totalpaper_num_cited + 1), 1) +
    lag(log(cumsum_rd + 0.0001),1) +
    lemp + lfasset  + year + zero_rd_dum
  
eq_roll_1 <-  lsale ~ lag(log(cumsum_total_num_cited +1),1) +
  lag(log(cumsum_totalpaper_num_cited +1),1) +
    lemp + lfasset  + year + zero_rd_dum
  
eq_roll_1 <-  log(cumsum_total_num_cited +1) ~ 
  lag(log(cumsum_totalpaper_num_cited +1),1) +
  lemp + lfasset  + year + zero_rd_dum

######
eq_roll_1 <-  lsale ~ lag(log(rollsum_3_copatent + 1), 5) +
  lag(log(rollsum_3_totalpatent - rollsum_3_copatent + 1), 5) +
  lag(log(rollsum_3_coauthor + 1), 5) +
  lag(lrd, 1) +
  lemp + lfasset  + year + zero_rd_dum

eq_roll_2 <-  lsale ~ lag(log(rollsum_3_copatent + 1), 5) +
  lag(log(rollsum_3_coauthor + 1), 5)+
  lag(lrd, 1) +lemp + lfasset  + year + zero_rd_dum

eq_roll_3 <- log(totalpatent + 1) ~ log(totalpaper + 1)  +
  lag(lrd, 1) + lemp + lfasset + year + zero_rd_dum


all1 <- pggls(eq_roll_1, model = "within",pdata)
all2 <- pggls(eq_roll_2, model = "within",pdata)
all3 <- pggls(eq_roll_3, model = "within",pdata)
summary(all3)



htmlreg(list(all1 %>% coeftest, all2 %>% coeftest, all3 %>% coeftest), file = "result1.doc", omit.coef = c("Inter.|year."),
         digits = 5,
        custom.coef.names = c("log rollsum3_copatent, lag2",
                              "log rollsum3_totalpatent-copatent, lag2",
                              "log rollsum3_coauthor lag2",
                              "log R&D inv, lag1",
                              "log employee",
                              "log fixed asset",
                              "log totalpaper",
                              rep(NA, 26)),
        custom.model.names = c("log sale", "log patent", "log patent"))

gic_reg_list <- list()

for (i in levels(pdata$gic3)) { 
  
    pf_ind <- plyr::failwith(NA,
      pggls)(eq_roll_1, data = subset(pdata, gic3 == i) , model = "within")
    
    if(is.na(pf_ind) == F){
      gic_reg_list[i] <- list(pf_ind %>% coeftest)
          } 
  
  }
}

data.frame(gic3 = levels(pdata$gic3), name = )

htmlreg(gic_reg_list, file = "result_gicnamed.html", omit.coef = "Inter.|year....",
        custom.coef.names = c("log rollsum3_copatent, lag2",
                              "log rollsum3_totalpatent-copatent, lag2",
                              "log rollsum3_coauthor lag2",
                              "log R&D inv, lag1",
                              "log employee",
                              "log fixed asset",
                              rep(NA, 22)),
        digits = 5,
        custom.model.names = c("Energy Equipment & Services",
                               "Oil, Gas & Consumable Fuels",
                                "Chemicals",
                                "Construction Materials",
                                "Containers & Packaging",
                                "Metals & Mining",
                                "Paper & Forest Products",
                                "Aerospace & Defense",
                                "Building Products",
                                "Construction & Engineering",
                                "Electrical Equipment",
                                "Industrial Conglomerates",
                                "Machinery",
                                "Trading Companies & Distribution",
                                "Commercial Services & Supplies ",
                                "Professional Services",
                                "Air Freight & Logistics",
                                "Airlines",
                                "Marine",
                                "Road & Rail",
                                "Auto Components",
                                "Automobiles",
                                "Health Care Equipment & Supplies",
                                "Health Care Provider & Services",
                                "Biotechnology",
                                "Pharmaceuticals",
                                "Life Sciences Tools & Services",
                                "Internet Software & Services",
                                "IT Services",
                                "Software",
                                "Communication Equipment",
                                "Computer & Peripherals",
                                "Electronic Equipment & Instruments",
                                "Semiconductors & Semiconductor Equipment",
                                "Diversified Telecommunication Services",
                                "Electric Utilities",
                                "Multi-Utilities"),
        custom.note = "dependent variable = log sale"
)
                                
                                
                                
                                





###
run_model(pdata, eq_roll_1)



######


for (i in levels(pdata$gic3)) { 
  if (datagic[gic3 == i, sum(copatent)] > 0) {
    pf_ind <- plm(eq_roll_1
                  , data = subset(pdata, gic3 == i)
                  , model = "within"
                  ) 
    
    temp <- lmtest::coeftest(pf_ind, vcov = pvcovHC)[1:6,]
    
 if (temp[3, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
     }
    
  }
}


posi_gic3 <- c(101010 )




for (i in levels(pdata$gic)) { 
  if (datagic[gic == i, sum(copatent)] > 0) {
    pf_ind <- plm(eq_roll_1
                  , data = subset(pdata, gic == i)
                  , model = "within"
    ) 
    
      temp <- lmtest::coeftest(pf_ind, vcov = pvcovHC)[1:6,]  
    
    
    
#    if (temp[3, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
 #   }
    
  }
}


posi_gic<- paste(c(15101030, 15101050, 15104020, 20107010,
                   20201060, 20201070, 20202010, 20305020,
                   45103020, 45203010, 45203015, 55103010))

for (i in levels(pdata$posi_gic)) { 
  if (datagic[gic3 == i, sum(copatent)] > 0) {
    pf_ind <- plm(lsale ~ lag(log(sum_3_copatent + 1), 2) + lag(log(sum_3_coauthor + 1), 2)
                  + lag(lrd, 1)
                  + lemp + lfasset  + year + zero_rd_dum
                  , data = subset(pdata, posi_gic == i)
                  , model = "within"
    ) 
    
    temp <- lmtest::coeftest(pf_ind, vcov = vcovHC)[1:5,]
    
  #  if (temp[3, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
   # }
    
  }
}





####
pf_np_1 <- gam(diff(lsale, 1) ~ s(diff(log(copatent + 1),1)) + s(diff(log(coauthor + 1), 1))
          + lag(diff(lrd, 1), 1) + diff(lemp, 1) + diff(log(fasset + 0.0001),1)
          + diff(zero_rd_dum, 1) + diff(factor(year), 1)
          , data = datagam)
summary(pf_np_1)
plot(pf_np_1)



###Knowledge Production Function
kf_1 <- plm(log(totalpatent + 1) ~lag(log(cumsum_copatent_num_cited + 1), 1) 
            + lag(log(cumsum_coauthor + 1), 1)
            + lag(log(cumsum_total_num_cited - cumsum_copatent_num_cited + 1), 1) + year
             + zero_rd_dum
          , data = pdata
          , model = "within"
)
summary(kf_2)



kf_po_1 <- pglm(totalpatent ~ lag(log(sum_3_copatent + 1), 1) + lag(log(sum_3_coauthor + 1), 1)
           + lag(lrd, 1)  + year
           , family = "negbin"
           , model = "within"
           , data = datagic
           )


summary(kf_2)
summary(kf_po_1)
summary(m2)

for (i in levels(pdata$gic)[49:80]) { 
  if (datagic[gic == i, sum(copatent)] > 0) {
    kf_ind <- plm(log(totalpatent + 1) ~ log(sum_3_copatent + 1) %>% lag(2) +
                    log(sum_3_coauthor + 1) %>% lag(2) + lag(lrd, 1) + year
                  , data = subset(pdata, gic == i)
                  , model = "within"
    )
    
    temp_s <- summary(kf_ind)
    
    if (temp_s$coefficients[2, 3] > 1.6) {
      
      message(i)
      temp_s$coefficients[1:3,]  %>% print(digit = 3)
      
    }
     

  }
}






















m3 <- pgmm(lsale ~ lag(lsale, 1 )
                 + lag(rollsum_3_copatent ,3)
                 + lag(rollsum_3_coauthor, 3)
           + lemp + lfasset
                  |lag(lrd,1) + lag(lemp, 2:99) + lag(lfasset, 2:99) 
           , effect = "twoway"
           , model = "onestep"
           , collapse = TRUE
           , data = pdata)
summary(m3, robust = T)

m33 <- pgmm(totalpatent ~ lag(totalpatent, 1 ) +
             lag(copatent, 1) + lag(coauthor, 1) +  lag(lrd, 1)
            |lag(copatent, 4:99) + lag(coauthor, 4:99) +  lag(lrd, 4:99)
           , effect = "twoway"
           , model = "onestep"
           , collapse = TRUE
           , data = pdata)


summary(m3, robust = TRUE)
summary(m33, robust = TRUE)



#########
htmlreg(pf_1, file = "pf.doc", omit.coef = c("Inter." , "year.")
        , digits = 5)

htmlreg(kf_1, file = "kf.doc"
        , omit.coef = c("Inter.", "country.", "year.", "gic.")
        , digits = 5)





