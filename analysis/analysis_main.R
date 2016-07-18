library(plm)

pdata <- plm.data(data, indexes = c("BvD ID number", "year"))


m1 <- plm(lsale ~ lag(copatent, 1)   + lag(coauthor ,1)
          + lag(lrd, 1) + lemp + ltasset  + country + year
          
          , data = pdata
          , model = "within"
          )

summary(m1)$coef[1:5,] %>% round(4)
summary(m1)

remove(m2)

m2 <- pgmm(lsale ~ lag(lsale, 1 ) 
                 + lag(coauthor ,1) + lag(copatent, 1)
                 + lrd + lemp + ltasset
                  |lag(lemp, 2:99) + lag(ltasset, 2:99)
           , effect = "twoway"
           , model = "onestep"
          , collapse = TRUE
          , data = pdata)

summary(m2)

$coef[1:4,] %>% round(4)
