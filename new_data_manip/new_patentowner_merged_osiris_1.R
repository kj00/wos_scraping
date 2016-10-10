source("data_manip/data_manip_env.R")

po <- read_csv("C:/Users/Koji/Orbis/patentowner.txt",
               col_types = cols_only("patentid" = col_character(),
                                     "bvdid" = col_character(),
                                     "name" = col_character()
                                     )
               )

po <- as.data.table(po)


#read osiris 
osiris <- fread("C:/Users/Koji/OneDrive/Research/wos_data/osiris_withRD.csv")
osiris <- osiris[order(rd_na)]
osiris_bvdid <- osiris[, `BvD ID number`] %>% as.data.table
remove(osiris)

#merge and restrict to osiris
po_merged_osiris <- merge(po, osiris_bvdid,
                          by.x = "bvdid", by.y = ".")

remove(osiris_bvdid)

#re-merge to recover information of co-owners
po_merged_osiris <- merge(po_merged_osiris, po,
                          by = "patentid",
                          all.x = T)
remove(po)
po_merged_osiris[, bvdid.y := NULL][, name.y := NULL]
colnames(po_merged_osiris) <- c("patentid", "bvdid", "name")


#count number of co-owner of each patent
gc()
po_merged_osiris[, num_coowner := uniqueN(name)  #bvdid can be deplicated for non firm owner 
                 , by = patentid]

po_merged_osiris[, name := NULL]

write_csv(po_merged_osiris,
          "C:/Users/Koji/Orbis/patentowner_merged_osiris.csv")

#po_merged_osiris[, num_coowner2 := uniqueN(bvdid), by = patentid]





