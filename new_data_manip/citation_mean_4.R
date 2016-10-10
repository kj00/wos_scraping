source("data_manip/data_manip_env.R")


pclass_list <- paste0("C://Users/Koji/Orbis/patentintclass_from",
                      c("1960_to1985",
                        "1985_to1995",
                        "1995_to2005",
                        "2005_tocurrent"), ".csv")

p_list <- paste0("C://Users/Koji/Orbis/patent_from",
                      c("1960_to1985",
                        "1985_to1995",
                        "1995_to2005",
                        "2005_tocurrent"), ".csv")


class_mean <- data.table(NULL)

for(i in 1:4) {
  ###
  pclass <- read_csv(pclass_list[i]) %>% 
    as.data.table
  colnames(pclass) <- c("patentid", "class")
  
  pclass[, class := str_extract(class, "^.")]
  pclass <- pclass %>% unique()
  
  
  ###
  pcite <- read_csv(p_list[i],
                    col_types = cols_only("patentid" = col_character(),
                                          "pubDate" = col_date("%Y-%m-%d"),
                                          "Nofcited" = col_integer())) %>% 
    as.data.table
  pcite[is.na(Nofcited), Nofcited := 0]
  pcite[, pubyear := year(pubDate)][, pubDate := NULL]
  
  ###
  d <- merge(pcite, pclass, by = "patentid")
  remove(pcite, pclass)
  
  
  
  temp <- d[,  mean(Nofcited), by = c("pubyear", "class")][order(pubyear, class)]
  
  class_mean <- rbind(class_mean, temp)
  
  remove(temp, d)
}

#
write_csv(class_mean, "C://Users/Koji/Orbis/patent_citation_mean.csv")



