source("data_manip/aggregate_data.R")

###
library(plm)
library(pglm)
library(mgcv)
library(texreg)
library(lmtest)

###
pdata <- plm.data(datagic, indexes = c("BvD ID number", "year"))

datagam<-datagic[,
                 .(lsale, copatent, coauthor, lrd, lemp, fasset, year, `BvD ID number`)] %>% 
  na.omit %>% as.data.frame

colnames(datagam)[8] <- "id"


              
######
pf_1 <- plm(lsale ~ lag(log(sum_3_copatent + 1), 2) + lag(log(sum_3_coauthor + 1), 2)
            + lag(lrd, 1)
            + lemp + lfasset  + year + zero_rd_dum
            , data = pdata
            , model = "fd"
)
coeftest(pf_1, vcov =  vcovHC)


######


for (i in levels(pdata$gic3)) { 
  if (datagic[gic3 == i, sum(copatent)] > 0) {
    pf_ind <- plm(lsale ~ lag(log(sum_3_copatent + 1), 2) + lag(log(sum_3_coauthor + 1), 2)
                  + lag(lrd, 1)
                  + lemp + lfasset  + year + zero_rd_dum
                  , data = subset(pdata, gic3 == i)
                  , model = "fd"
    ) 
    
    temp <- lmtest::coeftest(pf_ind, vcov = vcovHC)[1:5,]
    
    if (temp[2, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
    }
    
  }
}


posi_gic3 <- c(101010, )




for (i in levels(pdata$gic)) { 
  if (datagic[gic == i, sum(copatent)] > 0) {
    pf_ind <- plm(lsale ~ lag(log(sum_3_copatent + 1), 2) + lag(log(sum_3_coauthor + 1), 2)
                  + lag(lrd, 1)
                  + lemp + lfasset  + year + zero_rd_dum
                  , data = subset(pdata, gic == i)
                  , model = "fd"
    ) 
    
    temp <- lmtest::coeftest(pf_ind, vcov = vcovHC)[1:5,]
    
    if (temp[2, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
    }
    
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
    
    if (temp[2, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
    }
    
  }
}





####
pf_np_1 <- gam(lsale ~ s(log(copatent + 1)) + s(log(coauthor + 1))
          + lrd + lemp + log(1 + fasset)
          , data = datagam)





###Knowledge Production Function
kf_1 <- plm(log(totalpatent + 1) ~ log(sum_3_copatent + 1) %>% lag(2) +
              log(sum_3_coauthor + 1) %>% lag(2) + lag(lrd, 1) + year
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
                 + lag(copatent ,1) + lag(coauthor, 1)
                + lag(lrd, 1) + lemp + lfasset
                  |lag(lrd, 3:99) + lag(lemp, 2:99) + lag(lfasset, 2:99) 
           , effect = "twoway"
           , model = "onestep"
           , collapse = TRUE
           , data = pdata)

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





