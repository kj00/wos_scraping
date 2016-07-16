library(ff)
library(ffbase)
library(data.table)
library(magrittr)
library(stringr)
library(reshape2)
options(fftempdir="C:/Users/Koji/ff_temp")



po <- fread("C:/Users/Koji/Orbis/patentowner.txt", stringsAsFactors = T
            , drop = c(3, 4))

osiris <- fread("C:/Users/Koji/OneDrive/Research/wos_data/osiris_withRD.csv")
osiris <- osiris[order(rd_na)]
osiris_bvdid <- osiris[, `BvD ID number`] %>% as.data.table


po_merged <- merge(osiris_bvdid, po
                   , by.x = "."
                   , by.y = "bvdid")

write.csv(po_merged, "C:/Users/Koji/Orbis/patentowner_merged_osiris.csv")
po_merged <- fread("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv")


###########

p <- fread("C:/Users/Koji/Orbis/patent.txt", stringsAsFactors = T
            , drop = 3)


#################
osiris_patentid <- po_merged[, patentid] %>% as.data.table
remove(osiris_patentid)
remove(osiris_bvdid)
remove(p)
remove(po)

#===========
p_merged <- merge(osiris_patentid, p
                   , by.x = "."
                   , by.y = "patentid")


po_merged <- merge(po, p_merged
                   , by.x = "patentid"
                   , by.y = ".")

write.csv(po_merged, "C:/Users/Koji/Orbis/patent_merged_osiris_patentowner.csv")
po_merged <- fread("C:/Users/Koji/Orbis/patent_merged_osiris_patentowner.csv")

po_merged[, pubDate := str_extract(pubDate, "^....")] 
temp <- po_merged[, .N, by = patentid][N>1]
temp[, copatent := 1]
temp <- temp[, .(patentid, copatent)] %>% as.data.table

po_merged <- merge(po_merged, temp, by = "patentid", all.x = T)
colnames(po_merged)
po_merged[, V1 := NULL]

temp <- po_merged[, sum(copatent), by = .(bvdid, pubDate)][order(bvdid, -pubDate)]
write.csv(temp, "C:/Users/Koji/Orbis/copatent_osiris.csv")
