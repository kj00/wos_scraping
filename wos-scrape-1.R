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

source("search_and_download") 

etime <- Sys.time()
  
##send email  
source("send_email")

startloop <- i
