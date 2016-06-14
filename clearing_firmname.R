##prepare looping for firmname search

#read library
library(data.table)

#read firm data from OSIRIS
osiris <- fread("C:/Users/Koji/OneDrive/Research/wos_data/osiris_withRD.csv")
osiris <- osiris[order(rd_na)]

## clean names
osiris <- osiris[, c(3:4), with = F]
osiris[, order_na_id := 1:49057]
firm <- cbind(osiris[[1]], osiris[[2]])
  
#exclude signs except "&"
firm <- gsub("[^[:alnum:][:space:]]", " ", firm) 
#make it capital
firm <- toupper(firm) 

#input words to exclude "." means one letter.
remove1 <- c("INC", "LTD", "LIMITED", "AG", "A G", "COMPANY", "PLC","P L C", "CO", "CV", "C V", "S A B", "DE", "D E", "AND", "OR",
  "CORPORATION", "SA", "S A", "N V", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS","HOLDING", "STORE", "STORES", "ALLIANCE", "ALLIANCES") 


#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep = "", collapse = "|"), "", firm)

#exclude space at the end of string
firm <- gsub("^\\s+|\\s+$", "", firm)

#replace one or more spaces to one space
firm <- gsub("\\s+", " ", firm)

#for search, insert "and" in the space
firm_same <- gsub(" ", " same ", firm)
