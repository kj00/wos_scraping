#Read libraries
setwd("C:/Users/Koji/OneDrive/Research/wos_data")
library(foreach)
library(iterators)
library(doParallel)
library(stringr)
library(RSelenium)
library(data.table)


#======================================================================================================
##prepare looping for firmname search

#read data from OSIRIS
compname <- fread("compname.csv")

## clense names
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


#======================================================================================================
##prepare Rselenium driver

startServer()

#num_browser <- c("a", "b") #number of browsers

#create webdriver object
foreach (x = num_browser,
         .export = num_browser) %do% {
         assign(x, remoteDriver(remoteServerAddr = "localhost" 
                                              , port = 4444
                                              , browserName = "chrome")
         )
}


###open browsers and move to search page parallelcally 
foreach(x = num_browser,
        .export=num_browser,
        .packages = c("RSelenium", "stringr"))  %dopar% {

    #open browser
    get(x)$open()

    get(x)$navigate("http://www.wul.waseda.ac.jp/DOMEST/db_about/isi/wos.html")
    get(x)$navigate("http://webofknowledge.com/wos")
    Sys.sleep(3)
    #Engilish version
    get(x)$navigate("http://apps.webofknowledge.com/WOS_GeneralSearch_input.do?locale=en_US&errorKey=&viewType=input&SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=GeneralSearch&preferencesSaved=")
    
    #advanced search mode
    get(x)$navigate("http://apps.webofknowledge.com/WOS_AdvancedSearch_input.do?SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=AdvancedSearch")
    
    
    
    #log in
    webElem <-get(x)$findElement(using="id", value = "signin")
    webElem$clickElement()
    webElem <- get(x)$findElement(using="xpath", "//a[@class='subnav-link']")
    webElem$clickElement()
    webElem <- get(x)$findElement(using="id", value = "email")
    webElem$sendKeysToElement(list("kouji0925@hotmail.com"))
    webElem <- get(x)$findElement(using="id", value = "password")
    webElem$sendKeysToElement(list("N@tsumi21"))
    webElem <- get(x)$findElement(using="id", value = "signInImageEnabled")
    webElem$clickElement()
    
    Sys.sleep(10) # interval
        }#####foreach

    
    ###Search firm name
    #extract firmname and previous firmname
    firm<-gsub("\\W", " ", compname[607,c(2,6), with=F])
    firmname <- firm[[1]]
    prev_firmname <- firm[[2]]
    
   
    #define search code
    fieldtag<-c("OG", "OO", "FO")
    search<-c(
      paste("(",fieldtag, "=", c(firmname), "",")", collapse=" or ", sep=""),
              paste("(",fieldtag, "=", c(prev_firmname), "",")", collapse=" or ", sep="")
    )
              

    ##input search codes
    webElem <- $findElement(using = 'id', value="value(input1)")
    webElem$sendKeysToElement(list(search))
    
    ##choose document types
    webElem <- get(x)$findElement(using = 'id', value="value(input3)")
    webElem$sendKeysToElement(list("All document types"))
    
    ##enter
    webElem <- get(x)$findElement(using = 'id', value="searchButton")
    webElem$clickElement()
    
    ##match current history 
    webElem <- get(x)$findElement(using = 'class name', value="block-history") #find table of search history
    histable <- webElem$getElementAttribute("outerHTML")[[1]] #get html of the table
    histable <- data.frame(readHTMLTable(htmlParse(histable))) #parse and read table
    histnum <- as.character(histable[3,1])# number of current search hist
    papernum <- as.numeric(gsub(",","",histable[3,2])) # number of papers hit
    histnum <- gsub("[^0-9]","", histnum) #exclude character
    
    ##click current history
    webElem <- get(x)$findElement(using = c('id'), value=paste("set_",histnum,"_div", sep="")) #find current search bottun
    webElem$clickElement()
    
    
      
    # find total page numbers
    web_elm = get(x)$findElement(using="xpath", "//span[@id='hitCount.top']")
    #num_papers = web_elm$getElementText()[[1]] %>% str_replace(",", "") %>% as.numeric
    
    
    num_papers = as.numeric(gsub(web_elm$getElementText()[[1]],",", "")) 
        }

### common process

    
    #loop for downloading txt files
     foreach(i = icount(ceiling(num_papers/500))) %do% {
      
      elm_svopt = get(x)$findElement(using="id", value = "saveToMenu")
      elm_svopt$sendKeysToElement(list(  "Save to Other File Formats"))
      
      if (i != ceiling(num_papers/500)){
        
        elm_svopt = get(x)$findElement(using="id", value = "markFrom")
        elm_svopt$sendKeysToElement(list(paste(500*i-499)))
        elm_svopt = get(x)$findElement(using="id", value = "markTo")
        elm_svopt$sendKeysToElement(list(paste(500*i)))
        
        
      }
      
      else{
        elm_svopt = get(x)$findElement(using="id", value = "markFrom")
        elm_svopt$sendKeysToElement(list(paste(500*i-499)))
        elm_svopt = get(x)$findElement(using="id", value = "markTo")
        elm_svopt$sendKeysToElement(list(paste(num_papers)))
        
      }
      
      
      
      elm_svopt = get(x)$findElement(using="xpath", value = "//select[@id='bib_fields']")
      elm_svopt$sendKeysToElement(list("Full Record and Cited References"))
      elm_svopt = get(x)$findElement(using="xpath", value = "//select[@id='saveOptions']")
      elm_svopt$sendKeysToElement(list("Tab-delimited (Win, UTF-8)"))
      elm_svopt = get(x)$findElement(using="class", value = "quickoutput-action")
      elm_svopt$clickElement()
      Sys.sleep(10)
      elm_svopt = get(x)$findElement(using="class", value = "quickoutput-cancel-action")
      elm_svopt$clickElement()
      Sys.sleep(3)
    }
    }

    
 ##foreach        

####
stopImplicitCluster()
####



