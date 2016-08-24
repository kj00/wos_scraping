library(data.table)
library(magrittr)
library(stringr)
library(reshape2)
library(dplyr)

############
po <- fread("C:/Users/Koji/Orbis/patentowner.txt", stringsAsFactors = T
            , drop = c(3, 4))

osiris <- fread("C:/Users/Koji/OneDrive/Research/wos_data/osiris_withRD.csv")
osiris <- osiris[order(rd_na)]
osiris_bvdid <- osiris[, `BvD ID number`] %>% as.data.table
remove(osiris)

po_merged <- merge(osiris_bvdid, po
                   , by.x = "."
                   , by.y = "bvdid")
remove(po)
#write.csv(po_merged, "C:/Users/Koji/Orbis/patentowner_merged_osiris.csv")



#################
osiris_patentid <- po_merged[, patentid] %>% as.data.table
osiris_patentid <- fread("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv",
                     drop= 1:2) 

remove(osiris_bvdid)
remove(po_merged)

########publication date
p <- fread("C:/Users/Koji/Orbis/patent.txt", stringsAsFactors = T
           , drop = 3 #without number of cited
           ) 

p <- merge(osiris_patentid, p
                   , by = "patentid")
remove(osiris_patentid)
write.csv(p, "C:/Users/Koji/Orbis/patent_merged_osiris.csv")

#####number of cited
remove(p)
p_cited <- fread("C:/Users/Koji/Orbis/patent.txt", stringsAsFactors = T
           , drop = 2 #only number of cited
) 

p_cited <- merge(osiris_patentid, p_cited
           , by = "patentid")
remove(osiris_patentid)
write.csv(p_cited, "C:/Users/Koji/Orbis/patent_num_cited_merged_osiris.csv")

############
p_merged <- fread("C:/Users/Koji/Orbis/patent_merged_osiris.csv")
p_merged[, V1 := NULL]
p_merged <- merge(p_merged, p_cited, by = "patentid")
write.csv(p_merged, "C:/Users/Koji/Orbis/patent_complete_merged_osiris.csv")



#####
po_merged <- fread("C:/Users/Koji/Orbis/patentowner_merged_osiris.csv", drop = 1)
p_po_merged <- merge(po_merged, p_merged, 
                     by = "patentid", all.x = T)
write.csv(p_po_merged, "C:/Users/Koji/Orbis/patent_patentowner_merged_osiris.csv")



#copatent
p_po_merged[, pubDate := str_extract(pubDate, "^....")] #extract year of publication
p_po_merged[, num_patentid := .N, by = patentid] #count number of patentid
p_po_merged[num_patentid > 1 #restrict more than 2 ids
          , num_copatenter := uniqueN(.) #number of unique bvdid
          , by = patentid] #by patent id

p_po_merged[is.na(num_copatenter), num_copatenter := 1] #assign NA to 1


p_po_merged[num_copatenter > 1, copatent_dummy := 1] 
p_po_merged[is.na(copatent_dummy), copatent_dummy := 0] #assign NA to 1

#p_po_merged[1:100000, plot(copatent_dummy~num_copatenter)] ##check
p_po_merged[,]
p_po_merged[, copatent := sum(copatent_dummy),
                  by = .(., pubDate)]
p_po_merged[copatent_dummy == 1, 
            copatent_num_cited := sum(Nofcited %>% as.numeric),
                  by = .(., pubDate)]

#totalpatent in each year
p_po_merged[, patentid := NULL]
p_po_merged[,  `:=` (totalpatent =.N,
                   total_num_cited = sum(Nofcited %>% as.numeric)
                   )
                   , by = .(., pubDate)]


#p_po_merged[1:1000, plot(copatent~totalpatent, xlim = c(0,5000))] ##check

p_po_merged_aggregate <- unique(p_po_merged, by=c(".", "pubDate"))[order(., pubDate)]
remove(p_po_merged)
p_po_merged_aggregate[, `:=` (patentid = NULL
                          , num_patentid = NULL
                          , num_copatenter = NULL
                          , copatent_dummy = NULL
                          , Nofcited = NULL
                          )
                      ]
p_po_merged_aggregate[is.na(copatent_num_cited)
                      , copatent_num_cited := 0]

p_po_merged_aggregate[,  bvdid := .][, . := NULL]

write.csv(p_po_merged_aggregate, "C:/Users/Koji/Orbis/copatent_osiris.csv")
