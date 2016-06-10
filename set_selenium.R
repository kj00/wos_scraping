###prepare Rselenium drive
library(Rselenium)

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


#off-campus login
#remDr$navigate("http://apps.webofknowledge.com.ez.wul.waseda.ac.jp/WOS_AdvancedSearch_input.do?SID=N1tgckj7R4fbpOCcuUc&product=WOS&search_mode=AdvancedSearch")

