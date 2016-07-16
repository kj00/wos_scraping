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



