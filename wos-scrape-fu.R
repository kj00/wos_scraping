library(RSelenium)
#library(rvest)
startServer()
remDr <- remoteDriver(remoteServerAddr = "localhost" 
                      , port = 4444
                      , browserName = "chrome"
)


remDr$open()

##preparation
#waseda log-in
remDr$navigate("http://www.wul.waseda.ac.jp/DOMEST/db_about/isi/wos.html")
remDr$navigate("http://webofknowledge.com/wos")

#Engilish version
remDr$navigate("http://apps.webofknowledge.com/WOS_GeneralSearch_input.do?locale=en_US&errorKey=&viewType=input&SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=GeneralSearch&preferencesSaved=")

#advanced search mode
remDr$navigate("http://apps.webofknowledge.com/WOS_AdvancedSearch_input.do?SID=Y2gEKlianVazzeDIpIM&product=WOS&search_mode=AdvancedSearch")

#off-campus login
remDr$navigate("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/WOS_AdvancedSearch_input.do?SID=N1tgckj7R4fbpOCcuUc&product=WOS&search_mode=AdvancedSearch")

###Search firm name

##define search codes
firmname<-"TOYOTA"
fieldtag<-c("OG", "OO", "FO")
search<-paste("(",fieldtag, "=", firmname,"",")", collapse=" or ", sep="")

##input search codes
webElem <- remDr$findElement(using = 'id', value="value(input1)")
webElem$sendKeysToElement(list(search))

##choose document types
webElem <- remDr$findElement(using = 'id', value="value(input3)")
webElem$sendKeysToElement(list("All document types"))

##enter
webElem <- remDr$findElement(using = 'id', value="searchButton")
webElem$clickElement()

##match current history 
webElem <- remDr$findElement(using = 'class name', value="block-history") #find table of search history
histable <- webElem$getElementAttribute("outerHTML")[[1]] #get html of the table
histable <- data.frame(readHTMLTable(htmlParse(histable))) #parse and read table
histnum <- as.character(histable[3,1])# number of current search hist
papernum <- as.numeric(gsub(",","",histable[3,2])) # number of papers hit
histnum <- gsub("[^0-9]","", histnum) #exclude character

##click current history
webElem <- remDr$findElement(using = c('id'), value=paste("set_",histnum,"_div", sep="")) #find current search bottun
webElem$clickElement()


#click first paper
webElem <- remDr$findElement(using = 'class name', value="smallV110")
webElem$clickElement()


#get url
#baseurl<-remDr$getCurrentUrl()[[1]]


# ####rvest
# page <- read_html(baseurl)
# 
# #title
# title= page%>%html_nodes(css=".title")%>% html_text()
# title = gsub("\n","",title)
# 
# ##authors
# author = page %>% html_nodes(css = ".block-record-info") %>% 
#   html_nodes(css = ".FR_field") %>% html_nodes("a") %>% html_attrs()

#########################
##### Example by Fu #####
#########################
# remember to set number of entries per page to 50
remDr$navigate("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/summary.do?product=WOS&parentProduct=WOS&search_mode=AdvancedSearch&qid=1&SID=N1tgckj7R4fbpOCcuUc&page=1&action=changePageSize&pageSize=50")

# find total page numbers
web_elm = remDr$findElement(using="xpath", "//span[@id='pageCount.top']")
num_pages = web_elm$getElementText()[[1]] %>%
  str_replace(",", "") %>%
  as.numeric

for (i in 1:num_pages) {
  crt_page = i
  crt_url = paste("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/summary.do?product=WOS&parentProduct=WOS&search_mode=AdvancedSearch&qid=1&SID=N1tgckj7R4fbpOCcuUc&page=", 
                  i,
                  "&action=changePageSize&pageSize=50",
                  sep = "")
  remDr$navigate(crt_url)
  elm_svopt = remDr$findElement(using="xpath", value = "//span[@id='select2-chosen-1']")
  elm_svopt$clickElement()
  # you can find variable naems in the option value
  # PMID USAGEIND AUTHORSIDENTIFIERS ACCESSION_NUM FUNDING SUBJECT_CATEGORY JCR_CATEGORY LANG IDS PAGEC SABBR CITREFC ISSN PUBINFO KEYWORDS CITTIMES ADDRS CONFERENCE_SPONSORS DOCTYPE CITREF ABSTRACT CONFERENCE_INFO SOURCE TITLE AUTHORS  
  elm_svopt = remDr$findElement(using="xpath", value = "//select[@id='bib_fields']")
  elm_svopt$sendKeysToElement(list("Full Record and Cited References"))
  elm_svopt = remDr$findElement(using="xpath", value = "//select[@id='saveOptions']")
  elm_svopt$sendKeysToElement(list("Tab-delimited (Mac)"))
  elm_svopt$sendKeysToElement(list(using="class", value="quickoutput-action", key="enter"))
  Sys.sleep(10)
}
