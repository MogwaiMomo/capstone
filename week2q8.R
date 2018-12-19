
# get list of single unique words from all sources

# blog + news
blog.news.freq <- full_join(blog.freq, news.freq, by = "word") %>%
  mutate(blog.news.n = n.x + n.y) %>%
  select(-c(n.x, n.y))

# blog + news + twitter
all.freq <- full_join(blog.news.freq, twitter.freq, by = "word") %>%
  mutate(freq = blog.news.n + n) %>%
  select(word, freq)

# calculate 50%, 90% of word instances
sum.freq <- colSums(all.freq[,"freq"], na.rm = TRUE)
fifty.perc <- sum.freq * 0.5
ninety.perc <- sum.freq * 0.9

# create a while loop that adds up words in the list to its own table until freq hits 50%, 90%
setCoverage <- function(df, cov) {
  for(i in 1:nrow(df)) {
    tmp <- df[1:i, ]
    full.coverage <- colSums(df[,"freq"], na.rm = TRUE)
    coverage <- colSums(tmp[,"freq"], na.rm = TRUE) / full.coverage  
    if (coverage >= cov)
      break
  }
  return(nrow(tmp))
}