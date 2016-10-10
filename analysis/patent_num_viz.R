library(magrittr)
library(data.table)
library(stringr)
p <-  fread("C:/Users/Koji/Orbis/patent.txt",
           drop = 1,
           colClasses = c("factor", "factor", "integer"),
           showProgress = T,
           verbose = T,
           na.strings = "NULL"
           
) 

p[, pubDate := str_extract(pubDate, "^....")] #extract year of publication
p[, pubDate := as.integer(pubDate)]

p %>% str

p[Nofcited==0, .N]
p[is.na(Nofcited), .N]
p[, cited_null := is.na(Nofcited) %>% as.numeric]
p[is.na(Nofcited), Nofcited := 0]



temp1 <- p[, .N, by = pubDate][order(pubDate)]
temp2 <- p[, sum(Nofcited %>% as.integer()), by = pubDate][order(pubDate)][, V1]
temp3 <- p[, sum(cited_null %>% as.integer()), by = pubDate][order(pubDate)][, V1]


temp <- cbind(temp1, temp2, temp3)
temp[, ratio := temp2 / N]
colnames(temp) <- c("pub_year", "num_patent", "num_cited", "num_cited_null", "cited_per_patent")

library(ggplot2)
library(tidyr)

tidtemp <- temp %>% as.data.frame %>% gather(variable, value, -pub_year)


ggplot(tidtemp, aes(pub_year, value, colour = variable)) +
  geom_line() + facet_grid(variable~., scale="free")  +
  geom_vline(xintercept = 2002, colour = "#404040")
       
ggplot(temp, aes(pub_year, num_cited)) +
  geom_line()

write.csv(temp, "C://Users/Koji/Desktop/orbis_patent.csv")
