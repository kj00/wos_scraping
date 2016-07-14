library(MASS)
data[, year := as.factor(year)]
jid <- data[, .N, by = journal]
data <- merge(data, jid , by = "journal")

eq1 <- cited ~  I(num_country^2) + num_country + num_auth + I(num_auth^2) + I(univ/num_add) + I((univ/num_add)^2) +
                citing + year + wos_area + journal
eq2 <- cited ~  I(num_country^2) + num_country + num_auth + I(num_auth^2) +
                citing + year + wos_area + journal


m1 <- lm(eq1, data = data[N > 1])

m2 <- glm(eq1
  ,data = data[N>1]
  , family = "poisson") 

m3 <- glm(eq1
  ,data = data[type == "Article"][N > 1]
   , family = "poisson") 

m4 <- glm(formula = cited ~ I(num_country^2) + num_auth + I(univ/num_add) + 
            I((univ/num_add)^2) + citing + year + journal, family = "poisson", 
          data = data[type == "Article"][N > 1])

stepAIC(m3)

summary(m1)$coef[1:7,] %>% round(2)
summary(m2)$coef[1:7,] %>% round(2)
summary(m3)$coef[1:7,] %>% round(2)
summary(m4)$coef[1:7,] %>% round(3)

m4 <- glm.nb(eq1, data = data[N > 1])

summary(m4)$coef[1:6,] %>% round(2)

m1 <- lm(eq2, data = data[N > 1])

m2 <- glm(eq2
          ,data = data[N > 1]
          , family = "poisson") 

m3 <- glm(eq2
          ,data = data[type == "Article"][N > 1]
          , family = "poisson") 


summary(m1)$coef[1:7,] %>% round(2)
summary(m2)$coef[1:7,] %>% round(2)
summary(m3)$coef[1:7,] %>% round(2)
