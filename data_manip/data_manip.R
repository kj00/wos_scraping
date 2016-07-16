library(data.table)
library(magrittr)
library(stringr)
source("C:/Users/Koji/OneDrive/GitHub/animal/byplot.R")



#data <- fread("C:/Users/Koji/wos_data/wos_3_1.txt"
 # , encoding = "UTF-8", sep = "\t", skip = 2, header = F, verbose = T, na.strings = "")

#=================================================================================
#for (i in 499:1){
#test <- fread("C:/Users/Koji/wos_data/wos_3_1.txt"
#  , encoding = "UTF-8", sep = "\t", header = F, 
#  na.strings = "",skip = i,    verbose = T)
#message(i)
#}

#read.table("C:/Users/Koji/wos_data/wos_3_1.txt", header = F
# , skip = 3, sep = "\t", fill = F, quote = F)
#================================================================================


#V2:author names, V9:title, V10:journal name, V13:language, V14:doc type
#V23:author addresses, V24: recipient author address, V26-27:reseach ID,
#V28:funding agency and id, V31:citing number, V32:cited number
#V36:publisher, V37:publisher address1, V38:publisher address2, 
#V42:journal name2, V43:journal name3, V45:published year, 
#V57:???, V58:research area, V59:wos research area, V60:wos id

drop_col = c(3:8, 11, 12, 15:22, 25:27,  29, 30, 33:35, 39:41, 44,  46:57, 60, 62, 63)
drop_col2 = c(1:44,  46:60, 62:63)

new_colnames <- c("v1", "author", "title", "journal", "language"
  , "type", "author_address", "recipient", "funding", "citing"
  , "cited", "publisher", "pub_ad1", "pub_ad2", "jour_name2"
  , "jour_name3", "year", "area", "wos_area", "wos_id")

new_colnames2 <- c("year", "wos_id")


##get file list and order by id
  file_list <-   list.files(path = "C:/Users/Koji/wos_data/"
  , pattern = "*.txt") %>% 
    as.data.table %>%
  .[, `:=` (id1 = gsub("wos_|.txt", "", .) %>% gsub("_[0-9]+", "", .) %>% as.numeric
    , id2 = gsub("wos_|.txt", "", .) %>% gsub("[0-9]+_", "", .) %>%  as.numeric)]
  file_list %<>%  .[order(id1, id2)]




##loop to load all data
wos_data <- as.data.table(NULL)
prev_temp_store2 <- NULL
for (i in 1:length(file_list[, id1])) {
  
  temp_store <- as.data.table(NULL)  
  
  for (j in 1:length(file_list[id1 == i, id1])) {
    
    file_name <- paste("C:/Users/Koji/wos_data/wos_", i, "_", j, ".txt", sep = "")
    
    if (file.exists(file_name)) {
      
      temp  <-  fread(file_name
                      , drop = drop_col2, sep = "\t", skip = 1, na.strings = "")
      
      colnames(temp) <- new_colnames2
      temp <- temp[, .(year, wos_id)] %>% as.data.table
      
      temp_store <- rbind(temp_store, temp)
      
    }
  }
  
  if (identical(temp_store, as.data.table(NULL)) == FALSE) {
  
  temp_store2 <-  temp_store[, .N , by = year]
  temp_store2[, rn_id := file_list[i, id1]]

  }
  
  if (identical(temp_store2, prev_temp_store2) == FALSE){
  
  wos_data <- rbind(wos_data, temp_store2)
  
  }
  
  prev_temp_store2 <- temp_store2
  
(100 * i / length(file_list[,id1])) %>% round(1)  %>% message
  }





#################
data[, id := 1:nrow(data)]
data[, `:=` (
  
             num_auth = str_count(author, ";") + 1 #count ; to make "number of authors"
           , num_add = str_count(author_address, "\\[.+?\\]") %>% #extract number of []
                       gsub("0" , "1", .) %>% as.numeric #if there is no [], then 1
    
           , temp = str_extract_all(author_address, "(\\[.+?]).+?;|(\\[.+?]).+") #extract each [] and following address
              
  )][
    
    temp == "character(0)", temp := author_address #if there is no [], insert original address
    
    ][, `:=` 
    
             (country = lapply(temp, 
                                 function(x) str_extract(x, "\\s*\\w*$|\\s*\\w*;$") %>%
                                           gsub(" |;", "", .) %>%
                                           toupper 

                                             )
               
  )][, num_country := lapply(country, 
                               function(x) unique(x) %>% 
                                             length) %>% 
                      unlist
               
             ]

data[,  univ := lapply(temp, function(x) grepl("Univ|univ", x) %>% sum) %>% as.numeric][
  , num_add_univ := as.numeric(num_add) - as.numeric(univ)]

            

