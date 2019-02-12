library(magrittr)

mem_used()

sapply(ls(), function(x) object.size(get(x))) %>% 
  sort %>% 
  tail(5)


rm(-final_model)

mem_used()
