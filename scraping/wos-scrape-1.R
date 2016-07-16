#set working directry
setwd("C:/Users/Koji/OneDrive/GitHub/wos_scraping")

#
source("scraping/clearing_firmname.R")

#
source("scraping/set_selenium_chrome.R")

#source("set_selenium_firefox.R")


#======

#if nessesary
#remDr$navigate(baseurl[[1]])


#startloop <- 


#get base url
baseurl <- remDr$getCurrentUrl()
##startloop <- 1

###Loop for seaching firm names
stime <- Sys.time()

source("scraping/search_and_download_tryCatch.R") 
  
etime <- Sys.time()
  
##send email  
source("scraping/send_end_email.R")

startloop <- i -1
