source("new_data_manip/data_manip_env.R")

d <- read_csv("C://Users/Koji/Orbis/patent_final_aggregated.csv") %>% 
  as.data.table

##merge wos data
wos_data <- read_csv("C:/Users/Koji/wos.csv") %>% 
  as.data.table

source("old_version_data_manip/osiris_manip.R") #for rbid_bvdid

wos_data <- merge(wos_data, rdid_bvdid
                  , by.x = "rn_id"
                  , by.y = "order_na_id"
                  , all.x = TRUE)

d <- merge(d, wos_data,
           by.x = c("bvdid", "appyear"),
           by.y = c("BvD ID number", "year"),
           all.x = T)


osiris[, year := as.integer(year)]
d <- merge(d, osiris,
           by.x = c("bvdid", "appyear"),
           by.y = c("BvD ID number", "year"),
           all = T)

remove(osiris, wos_data, rdid_bvdid)

d[, year := appyear]
d[, X1 := NULL][, appyear := NULL]
d[,rn_id := NULL]


###stock
d[, year] %>% unique %>% .[order(.)]
d <- d[!(year %in% c(9999, 1929:1960))]



start_year <- 1961
end_year <- d[is.na(year) == F, year] %>% as.numeric %>% max
data_len <- d[, uniqueN(bvdid)]


#expand data by year
dummy <- data.table(year = rep.int(start_year:end_year, data_len), #integer
                    bvdid = rep(d[, unique(bvdid)], each = length(start_year:end_year)))
 

d <- merge(d, dummy, by = c("bvdid", "year"),
              all.y = T)
rm(dummy)

d <- d[order(bvdid, year)]

#define investment variavles and corresponding stock variables
inv_list <- d %>% colnames %>% .[3:18]
stock_list <- inv_list %>% paste0("_stock")

##set zero for patent, coaurthor
for (i in inv_list) {
  d[is.na(get(i)), i := 0, with = F]
}



##calucating stock function
stock_cal <- function(x, deprate) {
  
  stock <- rep(NA, length(x))
  stock[1] <- x[1]
  
  for (i in 2:length(x)){
    stock[i] <- stock[i - 1] * deprate + x[i]
  }
  
  return(stock)    
}

##
system.time(d[,  eval(stock_list) :=
                lapply(.SD, function(x) stock_cal(x, 0.85)),
              .SDcols = inv_list  ,by = bvdid])


ggplot(d[1:((2014 - 1961 + 1) * 100), ]) +
  geom_line(aes(year, total_patent, colour = bvdid)) 

ggplot(d[1:((2014 - 1961 + 1) * 100), ]) +
  geom_line(aes(year, total_patent_stock, colour = bvdid))


##
write_csv(d, "C:/Users/Koji/Orbis/new1.csv")

