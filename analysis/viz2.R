library(data.table)


data <- fread("C:/Users/Koji/Orbis/copatent_osiris.csv", drop = 1)
data[, pubDate := as.integer(pubDate)] #integer


temp1 <- data[, .(totalpatent, total_num_cited) %>% lapply(sum), by=pubDate,][order(pubDate)]
temp2 <- data[total_num_cited>0, uniqueN(bvdid), by = pubDate][order(pubDate)]
temp3 <- data[, sum(total_num_cited)/sum(totalpatent), by = pubDate][order(pubDate)]


temp <- cbind(temp1, temp2[, V1], temp3[, V1])
temp<- temp[-31]
colnames(temp) <- c("pub_year", "total_patent", "total_cited", "num_firm", "cite_ratio")

##
plot(V1~as.numeric(pubDate), type = "l", data = temp1)
abline(v=2002, col="red")
lines(temp$pubDate, temp$V1*10000, col="blue")
##

temptidy <- tidyr::gather(temp,
                          `total_patent`, `total_cited`, `num_firm`, `cite_ratio`,
                          key = "category",
                         value = "count")



library(ggplot2)
ggplot(temptidy) + geom_line(aes(pub_year, log(count), group = category, colour = category))

ggplot(temp) + geom_line(aes(pub_year, total_cited))

