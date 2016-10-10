source("data_manip/data_manip_env.R")

#read patentid merged osiris
osiris_patentid <- read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris_university.csv",
                                      col_types = cols_only("patentid" = col_character())
)

#only unique patentid
osiris_patentid <- unique(osiris_patentid)


#patent_filenames
patent_filenames <- paste0("C://Users/Koji/Orbis/patent_",
                           c("from2005_tocurrent",
                             "from1995_to2005",
                             "from1985_to1995",
                             "from1960_to1985"),
                             ".csv")

d <- as.data.table(NULL)

for(i in patent_filenames) {

  temp <- read_csv(i,
              col_types = cols("patentid" = col_character(),
                                 "pubDate" = col_date("%Y-%m-%d"),
                                 "appNumber" = col_character(),
                                 "Nofcited" = col_integer())
              ) %>% 
  as.data.table()


temp <- merge(temp, osiris_patentid, by = "patentid")

d <- rbind(d, temp)
rm(temp)
}
temp %>% head
rm(osiris_patentid)

d[, appDate := str_extract(appDate, "........$") %>% as.Date("%Y%m%d")]
#write_csv()
