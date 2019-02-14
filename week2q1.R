# Q1. Which text source is, on average, the longest format? The shortest?

blog.docs <- raw.blog.df %>%
  mutate(char_count = nchar(text)) %>%
  select(line, text, char_count)
blog.avg.char <- mean(blog.docs$char_count)

news.docs <- raw.news.df %>%
  mutate(char_count = nchar(text)) %>%
  select(line, text, char_count)
news.avg.char <- mean(news.docs$char_count)

twitter.docs <- raw.twitter.df %>%
  mutate(char_count = nchar(text)) %>%
  select(line, text, char_count)
twitter.avg.char <- mean(twitter.docs$char_count)

mean.doc.length <- list(
  "blog" = blog.avg.char,
  "news" = news.avg.char,
  "twitter" = twitter.avg.char
)

q1.max <- mean.doc.length[which.max(mean.doc.length)]
q1.min <- mean.doc.length[which.min(mean.doc.length)]

print(paste("The longest format is:", q1.max))
print(paste("The shortest format is:", q1.min))