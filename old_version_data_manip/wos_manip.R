library(data.table)
library(magrittr)
library(stringr)


paper_category <- fread("data/paper_category.csv")
included_category <- paper_category[is.na(unrelated) , category]


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
#V57:???, V58:wos research area, V59:research area, V61:wos id

#drop_col <-  c(3:8, 11, 12, 15:22, 25:27,  29, 30, 33:35, 39:41, 44,  46:57, 60, 62, 63)


#columns to drop
drop_col2 <-  c(1:13, 15:22, 24:31, 33:44,  46:57, 59:60, 62:63)

#new_colnames <- c("v1", "author", "title", "journal", "language"
#  , "type", "author_address", "recipient", "funding", "citing"
#  , "cited", "publisher", "pub_ad1", "pub_ad2", "jour_name2"
#  , "jour_name3", "year", "area", "wos_area", "wos_id")


#define column names
new_colnames2 <- c("doc_type", "address", "cited", "year", "wos_area", 
                   "wos_id", "num_add", "author_address_vec", "num_univ")


##get file list and ID number
  file_list <-   list.files(path = "C:/Users/Koji/wos_data/"
  , pattern = "*.txt") %>% 
    as.data.table %>%
  .[, `:=` (id1 = gsub("wos_|.txt", "", .) %>% gsub("_[0-9]+", "", .) %>% as.numeric
    , id2 = gsub("wos_|.txt", "", .) %>% gsub("[0-9]+_", "", .) %>%  as.numeric)]
  file_list %<>%  .[order(id1, id2)]




##loop to load all data

#preparation
wos_data_total <- as.data.table(NULL)
wos_data_coauthor <- as.data.table(NULL)
prev_temp_store2 <- NULL
prev_temp_store3 <- NULL

for (i in 1:length(file_list[, id1])) {
  
  #clearing temp_store for each loop
  temp_store <- as.data.table(NULL)  
  
  
  for (j in 1:length(file_list[id1 == i, id1])) {
    
    #get file name to read
    file_name <- paste("C:/Users/Koji/wos_data/wos_", i, "_", j, ".txt", sep = "")
  
    if (file.exists(file_name)) {
    
      #read the file  
      temp  <-  fread(file_name
                      , drop = drop_col2, sep = "\t", skip = 1, na.strings = "")
      
      temp[, `:=` (
         
           #number of addresses for each paper
           num_add = str_count(V23, "\\[.+?\\]") %>% #extract number of []
            gsub("0" , "1", .) %>% as.numeric,
           
           #vector of authors' address
           author_address_vec = 
             str_extract_all(V23,"(\\[.+?]).+?;|(\\[.+?]).+") #extract each [] and following address
        
        )
        ]
      
      temp[
        
        #extract obserbations whose author address vector is not correctly assigned
        author_address_vec == "character(0)",
        
        #if there is no [], insert original address
        author_address_vec := V23
        ]
      
      temp[,
           
           #number of universities in author address vector
           num_univ := lapply(author_address_vec,
                              function(x) grepl("Univ|univ", x) %>% sum) %>%
             as.numeric]
      
      #define column names
      colnames(temp) <- new_colnames2
      
      
      
      ##restrict observations
      #by wos area
      temp <- subset(temp,
             grepl(paste(included_category, sep = "", collapse = "|"), 
                   temp[, wos_area]))
      
      #observations related to analysis
      temp <- temp[
        
          #restrict year
          year > 1985][2016 > year][
            
            #restrict document tyoe
            doc_type == "Article"][
              
              #exclude papers involnving only Universities
              num_univ != num_add][, .(year, wos_id, cited, num_add)] %>%
        
        as.data.table
      
      #if observation remains at least 1, store the temp data
      if(nrow(temp) == 0) { } else {
      
          temp_store <- rbind(temp_store, temp)
          }
      }
  }
  
  #assure observation is more than 1
  if (identical(temp_store, as.data.table(NULL)) == FALSE) {
    
    
    ##extract data by year
    #number of address is more than one to assure coauthorship
    temp_store2 <-  temp_store[num_add > 1,
                               .(coauthor = .N, coauthor_num_cited = sum(cited)),
                               by = year]
    
    temp_store3 <- temp_store[, .(totalpaper = .N, totalpaper_num_cited = sum(cited)), by = year]
  



  #assign R&D NA ID  
    temp_store2[, rn_id := i] 
    temp_store3[, rn_id := i] 
    
  }
  
  #assure data is not dupulicated 
  if (identical(temp_store2, prev_temp_store2) == FALSE) {
  
  wos_data_coauthor <- rbind(wos_data_coauthor, temp_store2)
  
  }
  
  prev_temp_store2 <- temp_store2
  
  
  if (identical(temp_store3, prev_temp_store3) == FALSE) {
    
    wos_data_total <- rbind(wos_data_total, temp_store3)
    
  }
  
  prev_temp_store3 <- temp_store3
  
  
  
(100 * i / length(file_list[,id1])) %>% round(1)  %>% message
  }

##merge data
wos_data <- merge(wos_data_total, wos_data_coauthor,
      by = c("rn_id", "year"),
      all.x = TRUE)
remove(wos_data_coauthor, wos_data_total)

wos_data[is.na(coauthor), `:=` (coauthor = 0,
                                coauthor_num_cited = 0)]

#save resultig data

write.csv(wos_data, "C:/Users/Koji/wos.csv")




