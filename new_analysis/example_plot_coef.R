#=ISSUE=====================
#apply pggls and robust s.e.
#===========================


library(magrittr)
library(tidyverse)

#nest by industry
pdata %>%
  group_by(gic1) %>% #can be chaged by country
  nest() %>% 
  
  #run model
  mutate(model = map(data, ~ plm::plm(lsale %>% lead(2) ~ ltotal_patent + zero_total_patent_dum + lemp %>% 
                                   lead(2) + lfasset %>% lead(2) + zero_rd_dum + year + country,
                                   model = "within", data = .))) ->
  
  pgic



##model statistics
pgic %<>% mutate(glance = map(model, broom::glance),
                 rsq = map_dbl(glance, "r.squared"),
                augment = map(model, broom::augment),
                ci = map(model, broom::confint_tidy),
                tidy = map(model, broom::tidy),
                robust = map(model, ~ lmtest::coeftest(., vcov = plm::pvcovHC(.))),
                robust_tidy = map(robust, broom::tidy)
                )

##plot coeficients and CI
pgic %>% select(gic1, robust_tidy, ci) %>%
  unnest() %>% 
  filter(term == "lemp %>% lead(2)" | term == "lfasset %>% lead(2)") %>%
  arrange(desc(gic1)) %>% 
  ggplot(aes(reorder(gic1, estimate))) + 
  geom_point(aes(y = estimate, colour = term), size = 3) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high, colour = term), position = "dodge", width = 0.05) +
  ggthemes::theme_fivethirtyeight() +
  ggthemes::scale_colour_tableau() -> 
  gp

gp
plotly::ggplotly(gp)



###
pgic %>% select(gic1, robust_tidy, ci) %>%
    unnest() %>% 
    filter(stringr::str_detect(term, stringr::regex("^year"))) %>%
    arrange(desc(gic1)) %>% 
    group_by(gic1) %>% 
    mutate(year = 1990:2015) %>% 
    ggplot(aes(year, estimate)) + 
    geom_line(aes(colour = year), colour = NA, alpha = 0.7) +
  geom_point(aes(colour = year), size = 5) +
    geom_smooth(se = F) +
    facet_wrap(~gic1) + 
  ggthemes::theme_gdocs() + 
  viridis::scale_color_viridis() -> gp2

ggsave(plot = gp2, filename = "gp2.pdf")
plotly::ggplotly(gp2)





