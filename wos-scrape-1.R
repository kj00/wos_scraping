#set working directry
setwd("C:/Users/Koji/OneDrive/GitHub/wos_scraping")

#Read libraries
library(stringr)
library(RSelenium)
library(data.table)
library(mailR)


#
source("clearing_firmname")

#
source("set_selenium")



#======================================================================================================

#if nessesary
#remDr$navigate(baseurl[[1]])


#startloop <- 


#get base url
baseurl <- remDr$getCurrentUrl()


###Loop for seaching firm names
stime <- Sys.time()

  for (i in startloop:length(firm)) {
  
  ##define search codes
  fname <- firm[i, c(1)] #current firm name
  fpname <- firm[i, c(2)] #previous firm name
  
  fieldtag <- c("OG", "OO", "FO")
  
  if (fpname == ""){
    search <- paste("(", fieldtag, "=", fname, "", ")", collapse = " or ", sep="")
    
  } else {
    search <- paste(
      paste("(", fieldtag, "=", fname, "", ")", collapse = " or ", sep=""),
      " or ",
      paste("(", fieldtag, "=", fpname, "", ")", collapse = " or ", sep="")
      )
  }
  
  ##input search codes
  webElem <- remDr$findElement(using = 'id', value="value(input1)")
  webElem$clearElement()
  webElem$sendKeysToElement(list(search))
  
  ##choose document types
  webElem <- remDr$findElement(using = 'id', value="value(input3)")
  webElem$sendKeysToElement(list("All document types"))
  
  ##enter
  webElem <- remDr$findElement(using = 'id', value="searchButton")
  webElem$clickElement()
  
  ##match current history 
  webElem <- remDr$findElement(using = "xpath", "//*[@name='WOS_CombineSearches_input_form']") #find table of search history
  histable <- webElem$getElementAttribute("outerHTML")[[1]] #get html of the table
  histable <- data.frame(readHTMLTable(htmlParse(histable))) #parse and read table
  histnum <- as.character(histable[3,1])# number of current search hist
  papernum <- as.numeric(gsub(",","",histable[3,2])) # number of papers hit
  histnum <- gsub("[^0-9]","", histnum) 
  
  
  
  ## if no paper is hit, go next.
  if (papernum == 0) {next}
  
      
  
  #exclude character
  ##click current history
  webElem <- remDr$findElement(using = c('id'), value=paste("set_",histnum,"_div", sep="")) #find current search bottun
  webElem$clickElement()
  
  
  # find total page numbers
  webElem = remDr$findElement(using="xpath", "//span[@id='hitCount.top']")
  num_papers = webElem$getElementText()[[1]] %>%
    str_replace(",", "") %>%
    as.numeric
  
  
  #======================================================================================================
  ##loop for downloading txt files
  
    #input number of downloads
  num_dl<- ceiling(num_papers/500)
  
  
  for (j in 1:num_dl) {
  
    elm_svopt = remDr$findElement(using="id", value = "saveToMenu")
    elm_svopt$sendKeysToElement(list(  "Save to Other File Formats"))
    
    if (j != num_dl) {
    
      elm_svopt = remDr$findElement(using="id", value = "markFrom")
      elm_svopt$sendKeysToElement(list(paste(500*j-499)))
      elm_svopt = remDr$findElement(using="id", value = "markTo")
      elm_svopt$sendKeysToElement(list(paste(500*j)))
    
        }  else {
      
        elm_svopt = remDr$findElement(using="id", value = "markFrom")
        elm_svopt$sendKeysToElement(list(paste(500*j-499)))
        elm_svopt = remDr$findElement(using="id", value = "markTo")
        elm_svopt$sendKeysToElement(list(paste(num_papers)))
        
        }
    
    
    elm_svopt = remDr$findElement(using="xpath", value = "//select[@id='bib_fields']")
    elm_svopt$sendKeysToElement(list("Full Record and Cited References"))
    elm_svopt = remDr$findElement(using="xpath", value = "//select[@id='saveOptions']")
    elm_svopt$sendKeysToElement(list("Tab-delimited (Win, UTF-8)"))
    elm_svopt = remDr$findElement(using="class", value = "quickoutput-action")
    elm_svopt$clickElement()
    
    while (file.exists("C:/Users/Koji/Downloads/savedrecs.txt")==F) { } #wait downloading
    
    Sys.sleep(2)
    
    file.rename(from = "C:/Users/Koji/Downloads/savedrecs.txt", ##change file name
      to = paste("C:/Users/Koji/Downloads/wos_", i, "_", j, ".txt", sep=""))
    
    
    Sys.sleep(1)
    
    elm_svopt = remDr$findElement(using="class", value = "quickoutput-cancel-action")
    elm_svopt$clickElement()
    
    Sys.sleep(3)
    
    
  
    } # end loop for downloading
  
  
  
  #======================================================================================================
  
  ##return base url
  remDr$navigate(baseurl[[1]])
  
  ## check search history is near 100. if so, delete history
  if (i/99-round(i/99) == 0) {
    webElem <- remDr$findElement(using="class", value = "bselsets")
    webElem$clickElement()
    webElem <- remDr$findElement(using="xpath", "//*[@value='Delete selected sets']")
    webElem$clickElement()
    }
  
  
  } # end loop
  
  etime <- Sys.time()
  
  
  
  #=========================================================================================================
  source("send_email")
  
  #=========================================================================================================
  startloop <- i
