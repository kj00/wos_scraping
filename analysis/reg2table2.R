gic_reg_list <- list()

for (i in levels(pdata$gic3)) { 
  
  pf_ind <- plyr::failwith(NA,
                           pggls)(log(totalpatent + 1) ~ log(totalpaper + 1)  + lag(lrd, 1) + lemp + lfasset + year + zero_rd_dum,
                                  data = subset(pdata, gic3 == i) , model = "within")
  
  if(is.na(pf_ind) == F){
    gic_reg_list[i] <- list(pf_ind %>% coeftest)
  } 
  
}



htmlreg(gic_reg_list, file = "result_sb_gicnamed.html", omit.coef = "Inter.|year....",
        digits = 3,
        custom.coef.names = c(NA, "log R&D inv, lag1",
                              "log employee", "log fixed asset", rep(NA, 26)),
        custom.model.names = c("Energy Equipment & Services",
                               "Oil, Gas & Consumable Fuels",
                               "Chemicals",
                               "Construction Materials",
                               "Containers & Packaging",
                               "Metals & Mining",
                               "Paper & Forest Products",
                               "Aerospace & Defense",
                               "Building Products",
                               "Construction & Engineering",
                               "Electrical Equipment",
                               "Industrial Conglomerates",
                               "Machinery",
                               "Trading Companies & Distribution",
                               "Commercial Services & Supplies ",
                               "Professional Services",
                               "Air Freight & Logistics",
                               "Airlines",
                               "Marine",
                               "Road & Rail",
                               "Auto Components",
                               "Automobiles",
                               "Health Care Equipment & Supplies",
                               "Health Care Provider & Services",
                               "Biotechnology",
                               "Pharmaceuticals",
                               "Life Sciences Tools & Services",
                               "Internet Software & Services",
                               "IT Services",
                               "Software",
                               "Communication Equipment",
                               "Computer & Peripherals",
                               "Electronic Equipment & Instruments",
                               "Semiconductors & Semiconductor Equipment",
                               "Diversified Telecommunication Services",
                               "Electric Utilities",
                               "Multi-Utilities"),
        custom.note = "dependent variable = log totalpatent"
)


