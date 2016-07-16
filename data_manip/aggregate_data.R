source("data_manip/data_manip_env.R")
source("data_manip/osiris_manip.R")
source("data_manip/wos_manip.R")


po_count <- fread("C:/Users/Koji/Orbis/copatent_osiris.csv", drop = 1)
po_count[, copatent:= V1][, V1 := NULL]


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

wos_data[, coauthor := N][, N := NULL]
wos_data[, year := as.character(year)]

####
data  <- merge(data, rdid_bvdid
                      , by = "BvD ID number"
                      , all.x = TRUE)


data <- merge(data, wos_data[year > 1985][2016 > year]
              , by = c("BvD ID number", "year")
              , all.x = TRUE)

 
data[order(order_na_id)][, unique(order_na_id) %>% length]

data[is.na(coauthor), coauthor := 0]
data[is.na(copatent), copatent := 0]
data <- data[order_na_id < 956]
data[, order_na_id %>% unique %>% length]

##
#data2 <- data2[sale > 0][tasset >0][emp > 0]

##
data[, `:=` (lsale =log(sale)
             , lrd = log(rd + 0.000001)
             , lemp = log(emp)
             , ltasset = log(tasset))]

data[, country := `Country
code
(incorp)`]
data[, gis := as.factor(`GICS code`)]



remove(wos_data, rdid_bvdid)
