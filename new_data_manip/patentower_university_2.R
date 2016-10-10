source("data_manip/data_manip_env.R")

po_name <- read_csv("C:/Users/Koji/Orbis/patentowner.txt",
               col_types = cols_only("bvdid" = col_character()
                                     ,"name" = col_character())
) %>% as.data.table



po_name_univ <- 
  po_name[str_detect(name, regex("university", ignore_case = T))]

remove(po_name)

##reduce to unique bvdid
po_name_univ_t <- unique(po_name_univ[, .(bvdid, name)]) %>% as.data.table()
colnames(po_name_univ) <- "bvdid"


write_csv(po_name_univ, "C://Users/Koji/Orbis/patentowner_university.csv")