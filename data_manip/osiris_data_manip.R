library(data.table)
##R&D

colnames_osiris<- colnames(osiris)
osiris_long <- melt(osiris,
                    id.vars = colnames_osiris[5]
                    , measure.vars = colnames_osiris[6:32]
                    , variable.name = "rd", )
osiris_long[, rd := str_extract(rd, "....$")]
osiris_long <- osiris_long[order(`BvD ID number`, rd)]


##Sale

osiris <- 
  fread("C:/Users/Koji/Osiris/Osiris_sale_1_32258.csv", drop = 1:2, colClasses = rep("numeric", 31))


colnames_osiris<- colnames(osiris)
osiris_long <- melt(osiris,
                    id.vars = colnames_osiris[5]
                    , measure.vars = colnames_osiris[6:32]
                    , variable.name = "sale", )
osiris_long[, rd := str_extract(rd, "....$")]
osiris_long <- osiris_long[order(`BvD ID number`, rd)]
