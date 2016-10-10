source("data_manip/data_manip_env.R")

#patent_filenames
file_times <- c("from1960_to1985", "from1985_to1995", "from1995_to2005", "from2005_tocurrent")

patent_filenames <- paste0("C://Users/Koji/Orbis/patent_",
                           file_times,
                           ".csv")

weighted_citation_list <- paste0("C://Users/Koji/Orbis/patent_weighted_citation_from",
                     c("1960_to1985",
                       "1985_to1995",
                       "1995_to2005",
                       "2005_tocurrent"), ".csv")


 for(i in 1:4) {
   
   #read patentid merged osiris
   osiris_patentid <- read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris_university.csv",
                               col_types = cols_only("patentid" = col_character())
   ) %>% 
     as.data.table
   
  #read patentid
  tempid <- read_csv(patent_filenames[i],
                   col_types = cols_only("patentid" = col_character())
                                    
  ) %>% 
    as.data.table
  
  #merge patentid to osiris patentid
  tempid <- merge(tempid, osiris_patentid, by = "patentid")
  rm(osiris_patentid)
  
  #read whole osiris patent and merge
  osiris_patent <- read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris_university.csv") %>% 
    as.data.table
  temp <- merge(tempid, osiris_patent, by = "patentid")
  rm(osiris_patent, tempid)
  
  #read whole patent and merge
  patent <- read_csv(patent_filenames[i],
                     col_types = cols_only("patentid" = col_character(),
                                           "appNumber" = col_character(),
                                           "Nofcited" = col_integer()
                                           )
                     ) %>% 
    as.data.table
  
  
  temp <- merge(temp, patent, by = "patentid")
  rm(patent)
  
  ##
  citation_weighted <- read_csv(weighted_citation_list[i])
  
  temp <- merge(temp, citation_weighted, by = "patentid", all.x = T)
  remove(citation_weighted)
  
  #change appNumber to appDate and to year
  temp[, appNumber := str_extract(appNumber, "........$") %>% as.Date("%Y%m%d") %>% year]
  temp[, appyear := appNumber][, appNumber := NULL]
  
  
  
  write_csv(temp,  paste0("C://Users/Koji/Orbis/patent_new_aggregated",
                          file_times[i],
                          ".csv"))
  rm(temp)
}
