source("new_data_manip/data_manip_env.R")
d <- readr::read_csv("C:/Users/Koji/Orbis/new1.csv") %>%
  as.data.table

###
gis_country <- fread("C:/Users/Koji/Osiris/Osiris_gis_country.csv", drop = 1:2)
d <- merge(d, gis_country
              , by.x = "bvdid",
                by.y = "BvD ID number"
              , all.x = T)
remove(gis_country)

###Tobin's Q
q <- read_csv("C:/Users/Koji/Osiris/Osiris_tobinsq.csv")
q <- q[-1]
q %<>% tidyr::gather(year, tobin, -`BvD ID number`)
colnames(q)[1] <- "bvdid"
q$year %<>% as.integer() 
q$tobin %<>% as.numeric() 

d <- merge(d, q, by = c("bvdid", "year"), all.x = T)
rm(q)

###
d <- d[order(rn_id)]
d[,rn_id] %>% summary(na.rm=T)
d[, rn_id %>% uniqueN]


####
d <- d[rn_id < 9012]####


##
# d[sale > 0][tasset > 0][emp > 0][, uniqueN(rn_id)]
d <- d[year %in% 1985:2015]

##
d[, `:=` (lsale = log(sale)
             , lrd = log(rd)
             , lemp = log(emp)
             , lfasset = log(fasset))]

d[, country := `Country
code
(incorp)`]

d[, gic := as.factor(`GICS code`)]

d[, `Country
     code
     (incorp)` := NULL]
d[, `GICS code` := NULL]             

###exclude Finaince, sales, and so on.
d[, gic1 := str_extract(gic, "^..")]
d[, gic2 := str_extract(gic, "^....")]
d[, gic3 := str_extract(gic, "^......")]
datagic <- d[gic1 != "30"][gic1 != "40"][
  gic2 != "2520"][gic2 != "2530"][gic2 != "2540"][gic2 != "2550"][
    gic2 != "2030"
  ]


remove(wos_data, rdid_bvdid, data)

###
datagic[, `:=` (non_copatent_stock = total_patent_stock - copatent_nonuniv_stock - copatent_univ_stock - copatent_univ_other_stock,
                non_copatent_wcite_stock = total_patent_wcite_stock - non_univ_copatent_wcite_stock - only_univ_copatent_wcite_stock - univ_other_copatent_wcite_stock,
                copatent_univ_involved_stock =  copatent_univ_stock + copatent_univ_other_stock,
                univ_involved_copatent_wcite_stock = only_univ_copatent_wcite_stock + univ_other_copatent_wcite_stock)]


##dummy for 0 R&D, NA R&D
datagic[lrd == -Inf, zero_rd_dum := 1]
datagic[is.na(zero_rd_dum),  zero_rd_dum := 0]
datagic[lrd == -Inf, lrd := -5]

datagic[is.na(rd), na_rd_dum := 1]
datagic[is.na(na_rd_dum), na_rd_dum := 0]


###
str_extract_all(colnames(datagic), "bvdid|year|gic.|.?sale$|.?emp$|.?fasset$|.?rd$|country|.+stock$|.?tobin$|.+?dum") %>% 
  unlist %>% datagic[, ., with = F] -> datagic

colnames(datagic) %<>% str_replace("_stock", "")

###
stock_list <-  colnames(datagic)[c(7:19, 28:31)]

for (i in stock_list) {
  datagic[get(i) == 0, paste0("zero_", i, "_dum") := 1]
  datagic[get(i) != 0, paste0("zero_", i, "_dum") := 0]
  datagic[, paste0("l", i) := log(get(i))]
  datagic[get(paste0("zero_", i, "_dum")) == 1, paste0("l", i) := -5]
  }

#
datagic %>% colnames
datagic[, uniqueN(bvdid)]



