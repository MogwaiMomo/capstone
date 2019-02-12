library(pryr)
library(magrittr)

mem_used()

sapply(ls(), function(x) object.size(get(x))) %>% 
  sort %>% 
  tail(5)


rm(csv, training_probs)

mem_used()
