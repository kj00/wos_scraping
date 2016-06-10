#set working directry
setwd("C:/Users/Koji/OneDrive/Research/wos_data")

#Read libraries
library(stringr)
library(RSelenium)
library(data.table)
library(mailR)


###Input Values

#input start point of firm search
#startloop <- i +1

#input mail setting
sender <- "<kzfcv99@gmail.com>"
username <- "kzfcv9"
mailpass <- "sebangou22"

recipient <- "<kojih9@gmail.com>"  ## should be within Gmail


#======================================================================================================
##prepare looping for firmname search

#read data from OSIRIS
compname <- fread("compname.csv")

## clense names
firm <- compname[, c(2, 6, 3), with = F]
firm <- cbind(firm[[1]], firm[[2]])

firm <- gsub("[^[:alnum:][:space:]&]", " ", firm) #exclude signs except "&"
firm <- toupper(firm) #make it capital

#input words to exclude "." means one letter.
remove1 <- c("INC", "LTD", "LIMITED", "AG", "COMPANY", "PLC", "CO",
  "CORPORATION", "SA", "S A", "N V", "PARTNERSHIP", "GROUP", "CORP", "THE", "HOLDINGS", "STORE", "STORES", "ALLIANCE", "ALLIANCES") 


#exclude words
firm <- gsub(paste("\\<", remove1, "\\>", sep="", collapse = "|"), "", firm)

#exclude & at the end of string
firm <- gsub("&[[:space:]]*$", "", firm)

#==============================================================================================================




#======================================================================================================
##prepare Rselenium drive
startServer()
remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444
                      , browserName = "chrome"
)


remDr$open()
remDr$setTimeout(type = "page load", milliseconds = 30000)
remDr$setTimeout(type = "implicit", milliseconds = 30000)


#change download option---------------------

#getChromeProfile(getwd(), "profile1")

#this command enables opening "save as name"
#but default folder is still "download"....
#-------------------------------------------



##preparation
#waseda log-in
remDr$navigate("http://www.wul.waseda.ac.jp/DOMEST/db_about/isi/wos.html")
remDr$navigate("http://webofknowledge.com/wos")

#Engilish version
remDr$navigate("http://apps.webofknowledge.com/WOS_GeneralSearch_input.do?locale=en_US&errorKey=&viewType=input&SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=GeneralSearch&preferencesSaved=")

#advanced search mode
remDr$navigate("http://apps.webofknowledge.com/WOS_AdvancedSearch_input.do?SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=AdvancedSearch")

#login
webElem <- remDr$findElement(using="id", value = "signin")
webElem$clickElement()
webElem <- remDr$findElement(using="xpath", "//a[@class='subnav-link']")
webElem$clickElement()
webElem <- remDr$findElement(using="id", value = "email")
webElem$sendKeysToElement(list("kouji0925@hotmail.com"))
webElem <- remDr$findElement(using="id", value = "password")
webElem$sendKeysToElement(list("N@tsumi21"))
webElem <- remDr$findElement(using="id", value = "signInImageEnabled")
webElem$clickElement()

Sys.sleep(10)

#off-campus login
#remDr$navigate("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/WOS_AdvancedSearch_input.do?SID=N1tgckj7R4fbpOCcuUc&product=WOS&search_mode=AdvancedSearch")


#if nessesary
#-----------------------------------------------------------------------------------------------------
#remDr$navigate(baseurl[[1]])
#-----------------------------------------------------------------------------------------------------



#======================================================================================================
#Loop for seaching firm names
stime<-Sys.time()

#get base url
baseurl <- remDr$getCurrentUrl()
startloop <- 169
###
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
  
  
  
  ##check
  i ##ideal num of current finiched num of firm
  progress <- i - startloop
  current_state <- i / length(firm) * 100 #% of done
  rmin <- as.numeric(round((etime - stime) / 60, 1))
  fpermin <- progress / rmin
  remained <- length(firm) - i
  rhour <- round(remained / fpermin * (1 / 60), 1)
  rday <- round(rhour / 24, 1)
  #======================================================================================================
  #send email when loop ended
  send.mail(from = sender,
    to = recipient,
    subject = "Loop Ended",
    body = paste("current% is ", round(current_state,5), "%",
                 " : stopped at firm num = ", i, 
                 "  : run = ", rmin, 
                 " : num of progress = ", progress,
                 " : firm per min = " , fpermin,
                 " : estimated remaind time = ", rhour, " hours or ", rday, " days." ),
    smtp = list(host.name = "smtp.gmail.com",
                port = 465, 
                user.name = username,
                passwd = mailpass,
                ssl = TRUE),
    authenticate = TRUE,
    send = TRUE)
  
  
  
  #======================================================================================================
  startloop <- i
