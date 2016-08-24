library(ggplot2)

p <- ggplot(datagic)

p + geom_point(aes(log(coauthor + 1), lsale, colour = year)) + 
  facet_grid(facets = gic1 ~.)
  


datagic[, uniqueN(`BvD ID number`), by = gic3] %>%
  ggplot(.) + geom_histogram((aes(V1)))
