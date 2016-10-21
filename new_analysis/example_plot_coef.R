pdata %>%
  group_by(gic1)  %>%
  nest() %>% 
  mutate(model = map(data, ~ lm(sale ~  fasset, data = .))) ->
  pgic

pgic %<>% mutate(glance = map(model, broom::glance),
                 rsq = map_dbl(glance, "r.squared"),
                augment = map(model, broom::augment),
                ci = map(model, broom::confint_tidy),
                tidy = map(model, broom::tidy)
                coef = map(tidy)
                )

pgic %>% select(gic1, tidy, ci) %>%
  unnest %>% 
  filter(term == "fasset") %>%
  gather(name, ci, conf.low:conf.high) %>% 
  arrange(desc(gic1)) %>% 
  ggplot(aes(reorder(gic1, estimate))) + 
  geom_point(aes(y = estimate, colour = log(statistic))) +
  geom_line(aes(y = ci, group = gic1))


pgic %>% 
  ggplot(aes(rsq, reorder(gic1, rsq))) + geom_point()


