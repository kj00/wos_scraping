######
run_model <- function(data, eq, model = "within") {
  
  pm <- plm(eq_roll_1
              , data = data
              , model = model
  )
  
  coeftest(pm, vcov =  pvcovHC(pm))
  
}


########

run_model_bygic <- function(data, gic, eq, model = "within") {

    for (i in levels(data[gic])) { 
    
      temp_data <- subset(data, gic == i)
    
        if (temp_data["copatent"] %>% sum > 0) {

      
      temp <- run_model(temp_data, eq, model = model)[1:6,]

      
      # if (temp[2, 4] < 0.05) {
      
      message(i)
      print(temp, digit = 3)
      
      #}
      
    }
  }
  
}

