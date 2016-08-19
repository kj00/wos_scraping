library(data.table)
library(stringr)
library(magrittr)
##R&D ID
osiris_rd_id <- fread("C:/Users/Koji/Osiris/osiris_withRD.csv", drop = 1:2)

osiris_rd_id <- osiris_rd_id[order(rd_na)]
osiris_rd_id[, order_na_id := 1:49057]
rdid_bvdid <- osiris_rd_id[, .(order_na_id, `BvD ID number`)]
remove(osiris_rd_id)


##R&D
osiris_rd1 <- fread("C:/Users/Koji/Osiris/Osiris_rd_1_31250.csv", drop = 1:2)
osiris_rd2 <- fread("C:/Users/Koji/Osiris/Osiris_rd_31251_end.csv", drop = 1:2)

identical(colnames(osiris_rd1),colnames(osiris_rd2))

osiris_rd <- rbind(osiris_rd1, osiris_rd2)

remove(osiris_rd1, osiris_rd2)
colnames_osiris_rd <- colnames(osiris_rd)
osiris_rd_long <- melt(osiris_rd,
                    id.vars = colnames_osiris_rd[1]
                    , measure.vars = colnames_osiris_rd[2:29]
                    , variable.name = "year"
                    , value.name = "rd")

osiris_rd_long[, year := str_extract(year, "....$")]
osiris_rd_long <- osiris_rd_long[order(`BvD ID number`, rd)]
osiris_rd_long[, rd := gsub("\\(|\\)", "", rd)][, rd := as.numeric(rd)]


remove(osiris_rd)

##Sale

osiris_sale1 <- fread("C:/Users/Koji/Osiris/Osiris_sale_1_32258.csv", drop = 1:2)
osiris_sale2 <- fread("C:/Users/Koji/Osiris/Osiris_sale_32259_end.csv", drop = c(1:2, 32))

identical(colnames(osiris_sale1),colnames(osiris_sale2))

osiris_sale <- rbind(osiris_sale1, osiris_sale2)

remove(osiris_sale1,osiris_sale2)

colnames_osiris_sale <- colnames(osiris_sale)
osiris_sale_long <- melt(osiris_sale,
                    id.vars = colnames_osiris_sale[1]
                    , measure.vars = colnames_osiris_sale[2:29]
                    , variable.name = "year" 
                    , value.name = "sale")

osiris_sale_long[, year := str_extract(year, "....$")][order(`BvD ID number`, year)]
osiris_sale_long[, sale := gsub("\\(|\\)", "", sale)][, sale := as.numeric(sale)]
remove(osiris_sale)


##Employee

osiris_emp1 <- fread("C:/Users/Koji/Osiris/Osiris_employee_1_31250.csv", drop = 1:2)
osiris_emp2 <- fread("C:/Users/Koji/Osiris/Osiris_employee_31251_end.csv", drop = 1:2)

identical(colnames(osiris_emp1),colnames(osiris_emp2))

osiris_emp <- rbind(osiris_emp1, osiris_emp2)

remove(osiris_emp1,osiris_emp2)

colnames_osiris_emp <- colnames(osiris_emp)
osiris_emp_long <- melt(osiris_emp,
                         id.vars = colnames_osiris_emp[1]
                         , measure.vars = colnames_osiris_emp[2:29]
                         , variable.name = "year" 
                         , value.name = "emp")

osiris_emp_long[, year := str_extract(year, "....$")][order(`BvD ID number`, year)]
osiris_emp_long[, emp := gsub("\\(|\\)|,", "", emp)][, emp := as.numeric(emp)]
remove(osiris_emp)

###Total assets

osiris_tasset1 <- fread("C:/Users/Koji/Osiris/Osiris_totalasset_1_31250.csv", drop = 1:2)
osiris_tasset2 <- fread("C:/Users/Koji/Osiris/Osiris_totalasset_31251_end.csv", drop = 1:2)

identical(colnames(osiris_tasset1),colnames(osiris_tasset2))

osiris_tasset <- rbind(osiris_tasset1, osiris_tasset2)

remove(osiris_tasset1,osiris_tasset2)

colnames_osiris_tasset <- colnames(osiris_tasset)
osiris_tasset_long <- melt(osiris_tasset,
                        id.vars = colnames_osiris_tasset[1]
                        , measure.vars = colnames_osiris_tasset[2:29]
                        , variable.name = "year" 
                        , value.name = "tasset")

osiris_tasset_long[, year := str_extract(year, "....$")][order(`BvD ID number`, year)]
osiris_tasset_long[, tasset := gsub("\\(|\\)", "", tasset)][, tasset := as.numeric(tasset)]

remove(osiris_tasset)

###fixed assets

osiris_fasset1 <- fread("C:/Users/Koji/Osiris/Osiris_fixedasset_1_31250.csv", drop = 1:2)
osiris_fasset2 <- fread("C:/Users/Koji/Osiris/Osiris_fixedasset_31251_end.csv", drop = 1:2)

identical(colnames(osiris_fasset1),colnames(osiris_fasset2))

osiris_fasset <- rbind(osiris_fasset1, osiris_fasset2)

remove(osiris_fasset1, osiris_fasset2)

colnames_osiris_fasset <- colnames(osiris_fasset)
osiris_fasset_long <- melt(osiris_fasset,
                           id.vars = colnames_osiris_fasset[1]
                           , measure.vars = colnames_osiris_fasset[2:29]
                           , variable.name = "year" 
                           , value.name = "fasset")

osiris_fasset_long[, year := str_extract(year, "....$")][order(`BvD ID number`, year)]
osiris_fasset_long[, fasset := gsub("\\(|\\)", "", fasset)][, fasset := as.numeric(fasset)]

remove(osiris_fasset)

#######merge
osiris <- merge(osiris_rd_long, osiris_sale_long
                , by = c("BvD ID number", "year")
                , all.x = TRUE)

osiris <- merge(osiris, osiris_emp_long
                , by = c("BvD ID number", "year")
                , all.x = TRUE)

osiris <- merge(osiris, osiris_tasset_long
                , by = c("BvD ID number", "year")
                , all.x = TRUE)

osiris <- merge(osiris, osiris_fasset_long
                , by = c("BvD ID number", "year")
                , all.x = TRUE)


remove(osiris_tasset_long, osiris_emp_long, osiris_sale_long, osiris_rd_long, osiris_fasset_long)

