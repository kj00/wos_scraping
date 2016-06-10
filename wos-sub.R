###prepare looping for firmname search
# read data from OSIRIS
compname <- fread("compname.csv")

# clense names

###### NEED TO ADD PREVIOUS NAMES!! ######
firm <- compname[,c(2, 6, 3), with = F]
firm <- cbind(firm[[1]], firm[[2]])
id <- firm[[3]]

firm <- gsub("[^[:alnum:][:space:]&]", " ", firm) #exclude signs except "&"
firm <- toupper(firm) #make it capital


#input words to exclude "." means one letter.
remove1 <- c("INC", "LTD", "LIMITED", "AG", "COMPANY", "PLC", "MORTORS", "CO",
  "CORPORATION", "SA", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS") 

#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep="", collapse = "|"), "", firm)

#exclude & at the end of string
firm <- gsub("&[[:space:]]*$", "", firm)

#cbind firm id
firm <- cbind(firm, id)
firm <- as.data.table(firm)


#=========================================================================================================
#extract element
firm[1, "V1" := "hellow"] 
#assign new value
firm[1, (V1)]
