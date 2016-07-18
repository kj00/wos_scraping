library(data.table)
library(magrittr)
library(stringr)
library(reshape2)
library(dplyr)


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

#remove(osiris_patentid)
#remove(osiris_bvdid)
#remove(p)
#remove(po)

#===========
p_merged <- merge(osiris_patentid, p
                   , by.x = "."
                   , by.y = "patentid")


po_merged <- merge(po, p_merged
                   , by.x = "patentid"
                   , by.y = ".")

write.csv(po_merged, "C:/Users/Koji/Orbis/patent_merged_osiris_patentowner.csv")
po_merged <- fread("C:/Users/Koji/Orbis/patent_merged_osiris_patentowner.csv"
                   , drop = 1)

po_merged[, pubDate := str_extract(pubDate, "^....")]


#copatent
po_merged[,  num_patentid := .N, by = patentid] #count number of patentid
po_merged[num_patentid > 1 #restrict more than 2 ids
          , num_copatenter := uniqueN(bvdid) #number of unique bvdid
          , by = patentid] #by patent id

po_merged[is.na(num_copatenter), num_copatenter := 1] #assign NA to 1


po_merged[num_copatenter > 1, copatent_dummy := 1] 
po_merged[is.na(copatent_dummy), copatent_dummy := 0] #assign NA to 1
#po_merged[1:10000, plot(copatent_dummy~num_copatenter)] ##check

po_merged[, copatent := sum(copatent_dummy), by = .(bvdid, pubDate)]

#totalpatent in each year
po_merged[,  totalpatent :=.N  , by = .(bvdid, pubDate)]


#po_merged[1:1000, plot(copatent~totalpatent, xlim = c(0,5000))] ##check
po_merged[,  , by = .(bvdid, pubDate)][order(copatent)]
##

po_merged_aggregate <- unique(po_merged, by=c("bvdid", "pubDate"))[order(bvdid, pubDate)]
remove(po_merged)
po_merged_aggregate[, `:=` (patentid = NULL
                          , num_patentid = NULL
                          , num_copatenter = NULL
                          , copatent_dummy = NULL)]



write.csv(po_merged_aggregate, "C:/Users/Koji/Orbis/copatent_osiris.csv")
