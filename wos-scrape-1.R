#set working directry
setwd("C:/Users/Koji/OneDrive/GitHub/wos_scraping")

#
source("clearing_firmname.R")

#
source("set_selenium.R")



#======

#if nessesary
#remDr$navigate(baseurl[[1]])


#startloop <- 


#get base url
baseurl <- remDr$getCurrentUrl()
startloop <- 327


###Loop for seaching firm names
stime <- Sys.time()
source("search_and_download.R") 
  
etime <- Sys.time()
  
##send email  
source("send_email.R")

startloop <- i
