library(data.table)
library(magrittr)
source("C:/Users/Koji/OneDrive/GitHub/animal/byplot.R")



data <- fread("C:/Users/Koji/wos_data/wos_3_1.txt"
  , encoding = "UTF-8", sep = "\t", skip = 2, header = F, verbose = T, na.strings = "")


for (i in 499:1){
test <- fread("C:/Users/Koji/wos_data/wos_3_1.txt"
  , encoding = "UTF-8", sep = "\t", header = F, 
  na.strings = "",skip = 103,    verbose = T)
message(i)
}

read.table("C:/Users/Koji/wos_data/wos_3_1.txt", header = F
  , skip = 3, sep = "\t", fill = F, quote = F)


#V2:author names, V9:title, V10:journal name, V13:language, V14:doc type
#V23:author addresses, V24: recipient author address, V26-27:reseach ID,
#V28:funding agency and id, V31:citing number, V32:cited number
#V36:publisher, V37:publisher address1, V38:publisher address2, 
#V42:journal name2, V43:journal name3, V45:published year, 
#V57:???, V58:research area, V59:wos research area, V60:wos id

drop_col = c(3:8, 11, 12, 15:22, 25:27,  29, 30, 33:35, 39:41, 44,  46:57, 60, 62, 63)

new_colnames <- c("v1", "author", "title", "journal", "language"
  , "type", "author_address", "recipient", "funding", "citing"
  , "cited", "publisher", "pub_ad1", "pub_ad2", "jour_name2"
  , "jour_name3", "year", "area", "wos_area", "wos_id")



##get file list and order by id
  file_list <-   list.files(path = "C:/Users/Koji/wos_data/"
  , pattern = "*.txt") %>% 
    as.data.table %>%
  .[, `:=` (id1 = gsub("wos_|.txt", "", .) %>% gsub("_[0-9]+", "", .) %>% as.numeric
    , id2 = gsub("wos_|.txt", "", .) %>% gsub("[0-9]+_", "", .) %>%  as.numeric)]
  file_list %<>%  .[order(id1, id2)]




##loop to load all data
data <- as.data.table(NULL)
i <- 1
for (i in 1841:length(file_list)) {
  
  
  temp  <-  fread(paste("C:/Users/Koji/wos_data/", file_list[i, .], sep = "")
  , drop = drop_col, sep = "\t", skip = 1)


temp[, rn_id := file_list[i, id1]]
data <- rbind(data, temp)
(100 * i / length(file_list)) %>% round(1)  %>% message
 }

colnames(data) <- new_colnames
