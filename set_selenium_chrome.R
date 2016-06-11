###prepare Rselenium drive
library(RSelenium)

##
startServer()

remDr <- remoteDriver(remoteServerAddr = "localhost" 
  , port = 4444
  , browserName = "chrome"
)



##
remDr$open()

###timeout setting
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
loginmail <- remDr$findElement(using="id", value = "email")
loginmail$sendKeysToElement(list("kouji0925@hotmail.com"))
loginpass <- remDr$findElement(using="id", value = "password")
loginpass$sendKeysToElement(list("N@tsumi21"))#####
signin <- remDr$findElement(using="id", value = "signInImageEnabled")
signin$clickElement()


#off-campus login
#remDr$navigate("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/WOS_AdvancedSearch_input.do?SID=N1tgckj7R4fbpOCcuUc&product=WOS&search_mode=AdvancedSearch")

