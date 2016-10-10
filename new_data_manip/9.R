source("new_data_manip/data_manip_env.R")

d <- readr::read_csv("C:/Users/Koji/Orbis/new1.csv") %>% as.data.table

###
gis_country <- fread("C:/Users/Koji/Osiris/Osiris_gis_country.csv", drop = 1:2)
d <- merge(d, gis_country
              , by.x = "bvdid",
           by.y = "BvD ID number"
              , all.x = T)
remove(gis_country)


###
d[order(rn_id)]

####
d <- data[order_na_id < 9012]
data[,  %>% unique %>% length]

##
d <- d[sale > 0][tasset >0][emp > 0]

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


##
datagic[, rn_id := NULL][, V1 := NULL]
