source("new_data_manip/data_manip_env.R")

po_name <- read_csv("C:/Users/Koji/Orbis/patentowner.txt",
               col_types = cols_only("bvdid" = col_character()
                                     ,"name" = col_character())
) %>% as.data.table



po_name_univ <- 
  po_name[str_detect(name, regex("university", ignore_case = T))]

remove(po_name)

##reduce to unique bvdid
po_name_univ_t <- unique(po_name_univ[, .(bvdid, name)]) %>% as.data.table()

#duplication in names
po_name_univ_t[, .(uniN_bvdid = uniqueN(bvdid), uniN_name = uniqueN(name))]

#check duplicated names
po_name_univ_t[, dupli := (uniqueN(name) > 1)  , by = bvdid]
po_name_univ_t[dupli == 1]

#unique in bvdid is appropriate
po_name_univ_t2 <- unique(po_name_univ_t[, .(bvdid = bvdid)]) %>% as.data.table()





write_csv(po_name_univ_t2, "C://Users/Koji/Orbis/patentowner_university.csv")

remove(po_name_univ, po_name_univ_t, po_name_univ_t2)
