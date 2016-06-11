##prepare looping for firmname search

#read library
library(data.table)

#read firm data from OSIRIS
osiris <- fread("C:/Users/Koji/OneDrive/Research/wos_data/osiris_withRD.csv")




## clean names
osiris <- (osiris[, 2:4, with = F])

firm <- cbind(osiris[[2]], osiris[[3]])

#exclude signs except "&"
firm <- gsub("[^[:alnum:][:space:]&]", " ", firm) 
#make it capital
firm <- toupper(firm) 

#input words to exclude "." means one letter.
remove1 <- c("INC", "LTD", "LIMITED", "AG", "A G", "COMPANY", "PLC","P L C", "CO", "CV", "C V", "S A B", "DE", "D E",
  "CORPORATION", "SA", "S A", "N V", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS","HOLDING", "STORE", "STORES", "ALLIANCE", "ALLIANCES") 


#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep = "", collapse = "|"), "", firm)

#exclude & at the end of string
firm <- gsub("&[[:space:]]*$", "", firm)