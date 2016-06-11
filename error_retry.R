

error <- NULL
attempt <- 1

while(is.null(error) == T && attempt <= 3) {
  attempt <- attempt + 1
  tryCatch({
                               
    #
    #
    #
    #
    #
      
    error<- 1  
    
    }, error = function(e) {
      
      message("error comes")
      source("send_error_email")
      remDr$refresh()
      }
    )
  }
