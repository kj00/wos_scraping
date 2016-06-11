##prepare looping for firmname search

#read library
library(data.table)

#read firm data from OSIRIS
compname <- fread("C:/Users/Koji/OneDrive/Research/wos_data/compname.csv")

## clean names
firm <- compname[, c(2, 6, 3), with = F]
firm <- cbind(firm[[1]], firm[[2]])

#exclude signs except "&"
firm <- gsub("[^[:alnum:][:space:]&]", " ", firm) 
#make it capital
firm <- toupper(firm) 

#input words to exclude "." means one letter.
remove1 <- c("INC", "LTD", "LIMITED", "AG", "COMPANY", "PLC", "CO",
  "CORPORATION", "SA", "S A", "N V", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS", "STORE", "STORES", "ALLIANCE", "ALLIANCES") 


#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep = "", collapse = "|"), "", firm)

#exclude & at the end of string
firm <- gsub("&[[:space:]]*$", "", firm)
