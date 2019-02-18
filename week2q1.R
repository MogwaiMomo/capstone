# Q1. Which text source is, on average, the longest format? The shortest?

# load raw texts (using data.table)

raw.blog.df <- fread("raw_blog.csv", header=TRUE)
raw.news.df <- fread("raw_news.csv", header=TRUE)
raw.twitter.df <- fread("raw_twitter.csv", header=TRUE)

blog.docs <- raw.blog.df %>%
  mutate(char_count = nchar(text)) %>%
  select(doc_id, text, char_count)
blog.avg.char <- mean(blog.docs$char_count)

news.docs <- raw.news.df %>%
  mutate(char_count = nchar(text)) %>%
  select(doc_id, text, char_count)
news.avg.char <- mean(news.docs$char_count)

twitter.docs <- raw.twitter.df %>%
  mutate(char_count = nchar(text)) %>%
  select(doc_id, text, char_count)
twitter.avg.char <- mean(twitter.docs$char_count)

mean.doc.length <- list(
  "blog" = blog.avg.char,
  "news" = news.avg.char,
  "twitter" = twitter.avg.char
)

q1 <- data.table(
  q1.min = mean.doc.length[which.min(mean.doc.length)],
  q1.max = mean.doc.length[which.max(mean.doc.length)]
)

# save answer to file

fwrite(q1,file="q1.csv", quote = "auto")

# remove objects after saving

rm(list = ls())
