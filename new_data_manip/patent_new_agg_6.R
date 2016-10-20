source("new_data_manip/data_manip_env.R")

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
   osiris_patentid <- read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv",
                               col_types = cols_only("patentid" = col_character())
   ) %>% 
     unique %>% 
     as.data.table
   
  #read whole patent and merge
  patent <- read_csv(patent_filenames[i],
                     col_types = cols_only("patentid" = col_character(),
                                           "appNumber" = col_character()
                                           )
                     ) %>% 
    as.data.table
  
  
  patent <- merge(osiris_patentid, patent, by = "patentid")
  rm(osiris_patentid)
  ##
  citation_weighted <- read_csv(weighted_citation_list[i])
  
  patent<- merge(patent, citation_weighted, by = "patentid", all.x = T)
  remove(citation_weighted)
  
  #change appNumber to appDate and to year
  patent[, appNumber := str_extract(appNumber, "........$") %>% as.Date("%Y%m%d") %>% year]
  patent[, appyear := appNumber][, appNumber := NULL]
  
  
  #read patentid merged osiris
  osiris_patent_whole <- read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv",
                              col_types = cols_only("patentid" = col_character(),
                                                    "bvdid" = col_character(),
                                                    "num_coowner" = col_integer(),
                                                    "univ_dum" = col_integer())
  ) %>% as.data.table
  
  patent <- merge(patent, osiris_patent_whole, by = "patentid", all.x = T)
  rm(osiris_patent_whole)
  
  write_csv(patent,  paste0("C://Users/Koji/Orbis/patent_new_aggregated",
                          file_times[i],
                          ".csv"))
  rm(patent)
}
