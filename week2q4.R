# Q4. Which text source has HIGHEST word diversity (most # of words)? What about the LOWEST?

# Get total number of unique terms in each corpus

blog.freq <- tidy.blog %>%
  count(word, sort = TRUE)

news.freq <- tidy.news %>%
  count(word, sort = TRUE)

twitter.freq <- tidy.twitter %>%
  count(word, sort = TRUE)

total.words <- list(
  "blog" = nrow(blog.freq),
  "twitter" = nrow(twitter.freq),
  "news" = nrow(news.freq)
)

q4.max <- total.words[which.max(total.words)]
q4.min <- total.words[which.min(total.words)]

print(paste("The highest diversity format is:", q4.max))
print(paste("The lowest diversity format is:", q4.min))