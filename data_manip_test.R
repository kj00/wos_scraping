library(data.table)

osiris <- fread("osiris_withRD.csv", na.strings = "n.a.")
summary(osiris)
##
osiris$past_num
osiris$`Company name`

osiris[1] #extract rows
osiris[1:10]


osiris <- osiris[order(num_na)]
head(osiris)


#select columns
osiris[,]
identical(osiris, osiris[,])

osiris[, num_na] #as vector

osiris[, list(num_na)] #as data.table
osiris[, list(num_na, num)]
osiris[, .(num_na, num)]

osiris[, .(na_num = num_na, firm_id = num)] #select and rename columns


##comput or do in j
osiris[, sum(num_na)]

osiris[, .(num_na > 20)]

##subset i and j
osiris[num_na > 20 & num > 20000]
osiris[num_na < 20, .(firmid = num)]

##refer to columns by names
osiris[, c("num_na", "num"), with = FALSE]
osiris[, -c("num_na", "num"), with = FALSE]




#by number of colums


##aggregation

#grouping
osiris[, .(.N), by = .(num_na)] #.N is variable for number of observation
osiris[, .(.N), by = "num_na"]


###.SD
osiris[, print(.SD), by = num_na]

cols <- colnames(osiris)
osiris[, lapply(.SD, mean), keyby = num_na, .SDcols = 6:30]

###

osiris[num == NA] #R&D == NA
osiris[cols[6:30] == NA, cols[6:30], with=F] 
osiris[, get(cols[6:30])==NA, with=F] 

###
osiris[, num_na1 := Reduce(`+`, lapply(.SD,function(x) is.na(x)))]

osiris[, num_na2 := Reduce(`+`, lapply(.SD,function(x) is.na(x))), .SDcols =cols]

osiris[, num_na3 := Reduce(`+`, lapply(.SD,function(x) is.na(x))), .SDcols =cols[6:30]]

identical(osiris[, num_na1], osiris[, num_na2], osiris[, num_na3])

osiris[, paste("num_na", 1:3, sep =  "") := NULL]

###
osiris[, lapply(.SD, mean), .SDcols = cols[6:32]]



osiris[, num_nazero]

