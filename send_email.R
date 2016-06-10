##send email when loop ended

library(mailR)

#input mail setting
sender <- "<kzfcv9@gmail.com>"
username <- "kzfcv9"

#----
mailpass <- "sebangou22"  
#-----

recipient <- "<kojih9@gmail.com>"  ## should be within Gmail



#set email body items
progress <- i - startloop #number of firms done in the loop
current_state <- i / length(firm) * 100 #% of done
rmin <- as.numeric(round((etime - stime) / 60, 1)) #minites running
fpermin <- progress / rmin  #prossessed number of firms in the loop
remained <- length(firm) - i  #remained number of firms
rhour <- round(remained / fpermin * (1 / 60), 1)  #estimated processing hours
rday <- round(rhour / 24, 1)  #estimated processing days


#send email
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

