library(data.table)

drop_col = c(3:8, 11, 12, 15:22, 25,  29, 30, 41, 46:56, 60, 62, 63)

data <- fread("C:/Users/Koji/wos_data/wos_1_1.txt")
  , drop = drop_col)


#V28:funding agency

identical(data1, data2)


summary(data)



file_list






file_list <-   list.files(path = "C:/Users/Koji/wos_data/", pattern="*.txt")

for (i in 1:length(file_list)) {
   fread(paste("C:/Users/Koji/wos_data/", file_list[i], sep = "")))
}

cbind(wos_1_1.txt, wos_10_1.txt)
  