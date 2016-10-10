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

drop_col = c(1, 3:8, 11, 12, 15:22, 25:27,  29, 30, 33:35, 39:41, 44,  46:57, 60, 62:63)
drop_col2 = c(1:22, 24:44,  46:60, 62:63)
drop_col3 = c(1, 3:9, 11:12, 15:22, 25:27,  29, 30, 33:44,  46:57, 60, 62:63)

new_colnames <- c("author", "title", "journal", "language"
                  , "type", "author_address", "recipient", "funding", "citing"
                  , "cited", "publisher", "pub_ad1", "pub_ad2", "jour_name2"
                  , "jour_name3", "year", "area", "wos_area", "wos_id")

new_colnames2 <- c("address", "year", "wos_id", "num_add")

new_colnames3 <- c("author", "journal", "language", "type", "author_address", "recipient", "funding", "citing"
                  , "cited", "year", "area", "wos_area", "wos_id")


##get file list and order by id
file_list <-   list.files(path = "C:/Users/Koji/wos_data/"
                          , pattern = "*.txt") %>% 
  as.data.table %>%
  .[, `:=` (id1 = gsub("wos_|.txt", "", .) %>% gsub("_[0-9]+", "", .) %>% as.numeric
            , id2 = gsub("wos_|.txt", "", .) %>% gsub("[0-9]+_", "", .) %>%  as.numeric)]
file_list %<>%  .[order(id1, id2)]




##loop to load all data

samp_num <- 1000
samp_string <- sample(1:length(file_list[, id1]), samp_num)
wos_data2 <- as.data.table(NULL)

for (i in 1:samp_num)  {
  
      file_name <- paste("C:/Users/Koji/wos_data/", file_list[samp_string[i], .], sep = "")
    
      
      
      if (file.exists(file_name)) {
        
      temp  <-  fread(file_name
                        , drop = drop_col3, sep = "\t", skip = 1, na.strings = "")
      colnames(temp) <- new_colnames3
      
      temp <- temp[year > 1985][2010 > year]
      wos_data2 <- rbind(wos_data2, temp)
      
      }
      (100 * i / samp_num) %>% round(1)  %>% message
      
  }
  
#wos_data2 <- 
wos_data2 <-   unique(wos_data2, keyby = "wos_id")

  

#write.csv(wos_data2, "C:/Users/Koji/wos2.csv")











wos_data2[, id := 1:nrow(wos_data2)]
wos_data2[, `:=` (
  
  num_auth = str_count(author, ";") + 1 #count ; to make "number of authors"
 
   , num_add = str_count(author_address, "\\[.+?\\]") %>% #extract number of []
    gsub("0" , "1", .) %>% as.numeric #if there is no [], then 1
  
  , temp = str_extract_all(author_address, "(\\[.+?]).+?;|(\\[.+?]).+") #extract each [] and following address
  
)]

wos_data2[
  
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

wos_data2[,  univ := lapply(temp, function(x) grepl("Univ|univ", x) %>% sum) %>% as.numeric][
  , num_add_univ := as.numeric(num_add) - as.numeric(univ)]



