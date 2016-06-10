setwd("C:/Users/Koji/Downloads/")

###
data <-data.frame()
setwd("C:/Users/Koji/Downloads/Toyota")
library(data.table)

#data1 <-data.frame()
#for (i in 1:22) {
#  d <-   read.table(paste("savedrecs (",i,").txt", sep=""), sep = "\t",
#                   header = T, encoding = "UTF-8",
#                  row.names = NULL,
#                stringsAsFactors = F, na.strings = "",
#               comment.char = "", quote = "", fill=T,
#              colClasses = c(rep("character",29), "NULL", rep("character", 63-30)))
#  data1<-rbind(data1,d)
#}



data <-data.table()
for (i in 1:22) {
  d <-   fread(paste("savedrecs (",i,").txt", sep=""), sep = "\t")
  data<-rbind(data,d)
}
