###Loop for seaching firm names

##library
library(stringr)

##inputvalues
dldirect <- "C:/Users/Koji/Downloads/"

##start loop
for (i in andredo) {  #startloop:(length(firm) / 2)
  
  #-----------------------------------------------------------------------------------------------
  
  error <- NULL
  attempt <- 1
  
  while(is.null(error) == T && attempt <= 3) {
    attempt <- attempt + 1
    tryCatch({
      
      #-----------------------------------------------------------------------------------------------      
      
      ##return base url
      remDr$navigate(baseurl[[1]])
      baseurl <- remDr$getCurrentUrl()
      
      ## check search history is near 100. if so, delete history
      if (i / 99 - round(i / 99) == 0) {
        webElem <- remDr$findElement(using = "class", value = "bselsets")
        webElem$clickElement()
        webElem <- remDr$findElement(using = "xpath", "//*[@title='Delete selected sets']")
        webElem$clickElement()
        
      }
      
      ##define search codes
      fname <- firm_and[i, c(1)] #current firm name
      fpname <- firm_and[i, c(2)] #previous firm name
      
      fieldtag <- c("OG", "OO", "FO")
      
      if (fpname == "") {
        
        search <- paste("(", fieldtag, "=" , fname, ")", collapse = " or ", sep = "")
        
      } else {
        
        search <- paste(
          paste("(", fieldtag, "=", fname, ")", collapse = " or ", sep = ""),
          " or ",
          paste( "(", fieldtag, "=", fpname, ")", collapse = " or ", sep = "")
        )
        
      }
      
      ##input search codes
      webElem <- remDr$findElement(using = 'id', value = "value(input1)")
      webElem$clearElement()
      webElem$sendKeysToElement(list(search))
      
      ##choose document types
      #webElem <- remDr$findElement(using = 'id', value="value(input3)")
      #webElem$sendKeysToElement(list("All document types"))
      
      ##enter
      webElem <- remDr$findElement(using = "xpath", "//*[@title='Search']")
      webElem$clickElement()
      
      ##match current history 
      
      Sys.sleep(3)  

      ##sometimes error
      #find table of search history
      webElem <- remDr$findElement(using = "xpath", "//*[@name='WOS_CombineSearches_input_form']") 
      
      ###error
      
      
      
      histable <- webElem$getElementAttribute("outerHTML")[[1]] #get html of the table
      histable <- data.frame(readHTMLTable(htmlParse(histable))) #parse and read table
      histnum <- as.character(histable[3,1])# number of current search hist
      papernum <- as.numeric(gsub(",","", histable[3,2])) # number of papers hit
      histnum <- gsub("[^0-9]", "", histnum) 
      
      
      #-----------------------------------------------------------------------------------------------      
      
      error <- 1  
      
    }, error = function(e) {
      
      message("error comes")
      source("send_error_email.R")
      remDr$refresh()
      
    }
    )
  } #end while
  
  #-----------------------------------------------------------------------------------------------  
  
  
  
  #### if no paper is hit, go next.
  #=================================
  if (papernum == 0) {next}
  #=================================  
  
  
  
  
  #-----------------------------------------------------------------------------------------------
  
  error <- NULL
  attempt <- 1
  
  while(is.null(error) == T && attempt <= 3) {
    attempt <- attempt + 1
    
    tryCatch({
      
      #-----------------------------------------------------------------------------------------------      
      
      #exclude character
      ##click current history
      webElem <- remDr$findElement(using = c('id'), value = paste("set_", histnum, "_div", sep = "")) #find current search bottun
      webElem$clickElement()
      
      
      
      #-----------------------------------------------------------------------------------------------
      error <- 1  
      
    }, error = function(e) {
      
      message("error comes")
      source("send_error_email.R")
      remDr$refresh()
      
    }
    )
  } #end while
  
  #-----------------------------------------------------------------------------------------------  
  
  
  
  #======================================================================================================
  ##loop for downloading txt files
  
  #input number of downloads
  num_dl<- ceiling(papernum / 500)
  
  
  for (j in 1:num_dl) {
    
    
    
    #-----------------------------------------------------------------------------------------------
    error <- NULL
    attempt <- 1
    
    while(is.null(error) == T && attempt <= 3) {
      attempt <- attempt + 1
      tryCatch({
        
        webElem = remDr$findElement(using = "id", value = "saveToMenu")
        webElem$sendKeysToElement(list(  "Save to Other File Formats"))
        
        if (j != num_dl) {
          
          webElem = remDr$findElement(using = "id", value = "markFrom")
          webElem$sendKeysToElement(list(paste(500 * j - 499)))
          webElem = remDr$findElement(using = "id", value = "markTo")
          webElem$sendKeysToElement(list(paste(500 * j)))
          
        }  else {
          
          webElem = remDr$findElement(using = "id", value = "markFrom")
          webElem$sendKeysToElement(list(paste(500 * j - 499)))
          webElem = remDr$findElement(using = "id", value = "markTo")
          webElem$sendKeysToElement(list(paste(papernum)))
          
        }
        
        
        webElem = remDr$findElement(using = "xpath", value = "//select[@id='bib_fields']")
        webElem$sendKeysToElement(list("Full Record and Cited References"))
        webElem = remDr$findElement(using = "xpath", value = "//select[@id='saveOptions']")
        webElem$sendKeysToElement(list("Tab-delimited (Win, UTF-8)"))
        webElem = remDr$findElement(using = "class", value = "quickoutput-action")
        webElem$clickElement()
        
        while (file.exists(paste(dldirect, "savedrecs.txt", sep = "")) == F) { } #wait downloading
        
        
        file.rename(from = paste(dldirect, "savedrecs.txt", sep = ""), ##change file name
          to = paste(dldirect, "wos_", i, "_", j, ".txt", sep = ""))
        
        
        webElem = remDr$findElement(using = "class", value = "quickoutput-cancel-action")
        webElem$clickElement()
        
        Sys.sleep(1)
        #-----------------------------------------------------------------------------------------------        
        
        error <- 1
        
      }, error = function(e) {
        
        message("error comes")
        source("send_error_email.R")
        remDr$refresh()
        
      }
      )
    } #end while
    
    #-----------------------------------------------------------------------------------------------
    
  } # end loop for downloading
  
  #=====================  
  
} # end loop
