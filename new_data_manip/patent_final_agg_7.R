source("new_data_manip/data_manip_env.R")

#patent_filenames
file_times <- c("from2005_tocurrent", "from1995_to2005", "from1985_to1995", "from1960_to1985")
d <- as.data.table(NULL)

##looop

for (i in 1:4) {

temp <- read_csv(paste0("C://Users/Koji/Orbis/patent_new_aggregated",
                        file_times[i],
                        ".csv")) %>% as.data.table %>% unique


##count number of university owner by patent
#takes time 
temp[, num_coowner_univ := sum(univ_dum),
                 by = patentid]


##copatent dummy 
#not include university at all
temp[num_coowner > 1 & num_coowner_univ == 0, non_univ_copatent_dum := 1]
temp[is.na(non_univ_copatent_dum), non_univ_copatent_dum := 0]

#only university
temp[num_coowner > 1 & (num_coowner == (num_coowner_univ -1)),
     only_univ_copatent_dum := 1]
temp[num_coowner == num_coowner_univ, #name is university, bvdid is firm
     only_univ_copatent_dum := 1]
temp[is.na(only_univ_copatent_dum), only_univ_copatent_dum := 0]

#more than one univ and other co owner
temp[num_coowner > 1 & only_univ_copatent_dum == 0 & non_univ_copatent_dum == 0,
     univ_other_copatent_dum := 1]
temp[is.na(univ_other_copatent_dum), univ_other_copatent_dum := 0]

#check
temp[, sum(univ_other_copatent_dum)] + temp[, sum(only_univ_copatent_dum)] + temp[, sum(non_univ_copatent_dum)]

temp[num_coowner > 1, .N] + temp[num_coowner == 1 & num_coowner_univ == 1, .N]
temp[univ_other_copatent_dum + only_univ_copatent_dum + non_univ_copatent_dum == 1, .N]


###

dummy_names <- colnames(temp)[8:10]

for (j in dummy_names) {
  
  var_name <- j %>% str_replace("dum$", "wcite")
  
  temp[get(j) == 1,
       (var_name) := sum(wNofcited), 
       by = c("bvdid", "appyear")]
  
  temp[var_name %>% get %>% is.na, var_name := 0,
       with = F]

}

###aggregate by bvdid and appyear
temp <- temp[,
            .("total_patent" = uniqueN(patentid),
         "total_patent_wcite" = sum(wNofcited),
         "copatent_nonuniv" = sum(non_univ_copatent_dum),
         "copatent_univ" = sum(only_univ_copatent_dum),
         "copatent_univ_other" = sum(univ_other_copatent_dum),
         non_univ_copatent_wcite,
         only_univ_copatent_wcite,
         univ_other_copatent_wcite
         ),
         by = c("bvdid", "appyear")][order(bvdid, -appyear)] %>% unique

d <- rbind(d, temp)

rm(temp)

}

##aggregate again
d <- d[, lapply(.SD, sum), by = c("bvdid", "appyear")][order(bvdid, appyear)]

#
write_csv(d, "C://Users/Koji/Orbis/patent_final_aggregated.csv")
