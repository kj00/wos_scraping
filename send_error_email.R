###send error email when error happens

##library
library(mailR)

##input mail setting
sender <- "<kzfcv9@gmail.com>"
username <- "kzfcv9"

#----
mailpass <- "sebangou22"  
#-----

recipient <- "<kojih9@gmail.com>"  ## should be within Gmail



##set email body items

errortime <- Sys.time()

progress <- i - startloop #number of firms done in the loop
current_state <- (i * 100) / length(firm[, 1])  #% of done
rmin <- as.numeric(round((errortime - stime) , 1)) #minites running
fpermin <- progress / rmin  #prossessed number of firms in the loop
remained <- length(firm[, 1]) - i  #remained number of firms
rhour <- round(remained / fpermin * (1 / 60), 1)  #estimated processing hours
rday <- round(rhour / 24, 1)  #estimated processing days


##
mail_body <- paste(
  "attempt = ", attempt,
  "current% is ", round(current_state,5), "%",
  " : stopped at firm num = ", i, 
  " : run = ", rmin, 
  " : num of progress = ", progress,
  " : firm per min = " , fpermin,
  " : estimated remaind time = ", rhour, " hours or ", rday, " days." 
)

#send email
send.mail(from = sender,
  to = recipient,
  subject = "Error Happened",
  body = mail_body,
  smtp = list(host.name = "smtp.gmail.com",
    port = 465, 
    user.name = username,
    passwd = mailpass,
    ssl = TRUE),
  authenticate = TRUE,
  send = TRUE)

