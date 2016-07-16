##prepare looping for firmname search

#read library
library(data.table)

#read firm data from OSIRIS
osiris <- fread("C:/Users/Koji/Osiris/osiris_withRD.csv")
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
remove1 <- c("INC", "LTD", "LIMITED", "AG", "A G", "COMPANY", "PLC","P L C",
  "PCL","CO", "CV", "C V", "S A B", "DE", "D E", "AND", "OR", "SPA", "S A P",
  "AB", "A B", "PUBL", "ASA", "A S A" ,"AS", "A S",
  "CORPORATION", "SA", "S A", "NV", "N V", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS","HOLDING", "STORE", "STORES", "ALLIANCE", "ALLIANCES") 


#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep = "", collapse = "|"), "", firm)

#exclude space at the end of string
firm <- gsub("^\\s+|\\s+$", "", firm)

#replace one or more spaces to one space
firm <- gsub("\\s+", " ", firm)

#for search, insert "and" in the space
firm_same <- gsub(" ", " same ", firm)


########
firm <- as.data.frame(firm, stringsAsFactors = F)
firm_same <- as.data.frame(firm_same, stringsAsFactors = F)

firm$wdnum <- sapply(gregexpr("\\W+", firm[,1]), length)
firm$ltnum <- sapply(firm[,1], nchar)
firm$pwdnum <- sapply(gregexpr("\\W+", firm[,2]), length)
firm$pltnum <- sapply(firm[,2], nchar)


for(i in 1:nrow(firm))
    if(firm$ltnum[i] < 2) {
      firm$V1[i] <- gsub("[^[:alnum:][:space:]]", " ", osiris$`Company name`[i]) 
      firm_same$V1[i] <- gsub("[^[:alnum:][:space:]]", " ", osiris$`Company name`[i])
      }

  
#c(24247, 29124, 36127, 39417) ## 0 letter
#c(1314, 1652, 17329, 25139, 29031) ## 1 letter
