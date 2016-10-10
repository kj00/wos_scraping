data <- fread("C:/Users/Koji/Orbis/copatent_osiris.csv", drop = 1)

data[, pubDate := as.integer(pubDate)] #integer

start_year <- data[is.na(pubDate) == F, pubDate] %>% as.numeric %>% min
end_year <- data[is.na(pubDate) == F, pubDate] %>% as.numeric %>% max
data_len<- data[, bvdid %>% uniqueN]

#expand data by year
dummy <- data.table(pubDate = rep.int(start_year:end_year, data_len), #integer
                    bvdid = rep(data[, bvdid %>% unique], each = length(start_year:end_year)),
                    dummy = rep(NA, data_len * length(start_year:end_year)))

data <- merge(data, dummy, by = c("pubDate", "bvdid"),
              all.y = T)

data <- data[order(pubDate, bvdid)]
data[, dummy := NULL]

#cariculate stock
dep_rate <- 0.15

inv_list <- data %>% colnames %>% .[3:6]
stock_list <- data %>% colnames %>% .[3:6] %>% paste0("_stock")
lag_stock_list <- data %>% colnames %>% .[3:6] %>% paste0("_stock_lag")


data[, stock_list := as.numeric(0), with = F]
data[pubDate == start_year, stock_list := lapply(.SD, as.numeric),
     .SDcols = inv_list,
     by = bvdid, with = F]

data[,  lag_stock_list := shift(.SD, n = 1, type = "lag"),
     .SDcols = stock_list,
     by = bvdid, with = F]

 

for(i in (start_year + 1):end_year) {
    
  data[pubDate == i,
         stock_list := lapply(inv_list, lag_stock_list * (1- dep_rate)),
         by = bvdid, with = F]
  data[,  lag_stock_list := shift(.SD, n = 1, type = "lag"),
       .SDcols = stock_list,
       by = bvdid, with = F]
  
    }
  


##
data[, lag_stock_list := NULL]
write.csv(data, "C:/Users/Koji/Orbis/stock_copatent_osiris.csv")





