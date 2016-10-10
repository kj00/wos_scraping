source("data_manip/data_manip_env.R")
source("data_manip/osiris_manip.R")
#source("data_manip/wos_manip.R")


po_count <- fread("C:/Users/Koji/Orbis/stock_copatent_osiris.csv", drop = 1)
po_count[, pubDate := as.character(pubDate)]
wos_data <- fread("C:/Users/Koji/wos.csv")

data <- merge(osiris, po_count
              , by.x = c("BvD ID number", "year")
              , by.y = c("bvdid", "pubDate")
              , all.x = T)

remove(osiris, po_count)

gis_country <- fread("C:/Users/Koji/Osiris/Osiris_gis_country.csv", drop = 1:2)


data <- merge(data, gis_country
              , by = "BvD ID number"
              , all.x = T)

remove(gis_country)


###
wos_data[, rn_id := as.factor(rn_id)]

wos_data <- merge(wos_data, rdid_bvdid
                  , by.x = "rn_id"
                  , by.y = "order_na_id"
                  , all.x = TRUE)

wos_data[, year := as.character(year)]

####
data  <- merge(data, rdid_bvdid
                      , by = "BvD ID number"
                      , all.x = TRUE)


data <- merge(data, wos_data[year > 1985][2016 > year]
              , by = c("BvD ID number", "year")
              , all.x = TRUE)

 
data[order(order_na_id)][, unique(order_na_id) %>% length]

data[is.na(coauthor), `:=` (coauthor = 0, coauthor_num_cited = 0)]
data[is.na(copatent), `:=` (copatent = 0, copatent_num_cited = 0)]
data[is.na(totalpatent), `:=` (totalpatent = 0, total_num_cited = 0)]
data[is.na(totalpaper), `:=` (totalpaper = 0, totalpaper_num_cited = 0)]

####
data <- data[order_na_id < 9012]
data[, order_na_id %>% unique %>% length]

##
data <- data[sale > 0][tasset >0][emp > 0]

##
data[, `:=` (lsale =log(sale)
             , lrd = log(rd)
             , lemp = log(emp)
             , lfasset = log(fasset))]

data[, country := `Country
code
(incorp)`]

data[, gic := as.factor(`GICS code`)]

data[, `Country
code
(incorp)` := NULL]
data[, `GICS code` := NULL]             

###exclude Finaince, sales, and so on.
data[, gic1 := str_extract(gic, "^..")]
data[, gic2 := str_extract(gic, "^....")]
data[, gic3 := str_extract(gic, "^......")]
datagic <- data[gic1 != "30"][gic1 != "40"][
  gic2 != "2520"][gic2 != "2530"][gic2 != "2540"][gic2 != "2550"]


remove(wos_data, rdid_bvdid, data)


##dummy for 0 R&D, NA R&D
datagic[lrd == -Inf, zero_rd_dum := 1]
datagic[is.na(zero_rd_dum),  zero_rd_dum := 0]
datagic[lrd == -Inf, lrd := 0]

datagic[is.na(rd), na_rd_dum := 1]
datagic[is.na(na_rd_dum), na_rd_dum := 0]
datagic[is.na(total_num_cited), total_num_cited := 0]
datagic[is.na(copatent_num_cited), copatent_num_cited := 0]
datagic[is.na(totalpatent_stock), totalpatent_stock := 0]

###rollsum
datagic[, num_year := length(year), by = `BvD ID number`]

library(zoo)
sumlist <- c("rd", "copatent", "coauthor", "totalpatent", "totalpaper",
             "total_num_cited", "copatent_num_cited",
             "coauthor_num_cited", "totalpaper_num_cited")
rollyear <- 3


datagic[num_year > rollyear, paste("rollsum", rollyear, sumlist, sep = "_") := 
          lapply(.SD, rollsum, k = rollyear, na.pad = F),
        by = `BvD ID number`, .SDcols = sumlist]


###cumsum
datagic[, paste("cumsum", sumlist, sep ="_") := 
          lapply(.SD, cumsum),
        by = `BvD ID number`, .SDcols = sumlist]




##
datagic[, rn_id := NULL][, V1 := NULL]