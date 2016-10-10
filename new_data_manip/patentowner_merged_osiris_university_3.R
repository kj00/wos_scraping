source("data_manip/data_manip_env.R")
##read osiris patent owner
po_merged_osiris <-
  read_csv("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv") %>% 
  as.data.table()

#read university owner id
po_name_univ <- read_csv("C:/Users/Koji/Orbis/patentowner_university.csv",
           col_types = cols_only("bvdid" = col_character()
                                 )
           ) %>% 
   as.data.table

#set university dummy
po_name_univ[, univ_dum := as.integer(1)]

#merge
po_merged_osiris <- merge(po_merged_osiris, po_name_univ,
                          by = "bvdid",
                          all.x = T)
remove(po_name_univ)
po_merged_osiris[is.na(univ_dum), univ_dum := as.integer(0)]

##count number of university owner by patent
#takes time 
po_merged_osiris[, num_coowner_univ := sum(univ_dum),
                 by = patentid]

#only unique ones
po_merged_osiris <- unique(po_merged_osiris, by = c("bvdid", "patentid"))

#save
write_csv(po_merged_osiris,
          "C:/Users/Koji/Orbis/patentowner_merged_osiris_university.csv")

