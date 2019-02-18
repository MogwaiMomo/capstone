# Q1. Which text source is, on average, the longest format? The shortest?

# load raw texts (using data.table)

raw.blog.df <- fread("raw_blog.csv", header=TRUE)
raw.news.df <- fread("raw_news.csv", header=TRUE)
raw.twitter.df <- fread("raw_twitter.csv", header=TRUE)

raw.dfs <- list(
  blog = raw.blog.df,
  news = raw.news.df,
  twitter = raw.twitter.df
)

blog.avg.char <- mean(raw.blog.df$char_count)
news.avg.char <- mean(raw.news.df$char_count)
twitter.avg.char <- mean(raw.twitter.df$char_count)


mean.doc.length <- list(
  "blog" = blog.avg.char,
  "news" = news.avg.char,
  "twitter" = twitter.avg.char
)

q1 <- data.table(
  q1.min = mean.doc.length[which.min(mean.doc.length)],
  q1.max = mean.doc.length[which.max(mean.doc.length)]
)

# raw texts from source
for (i in 1:length(raw.dfs)) {
  fwrite(raw.dfs[[i]],file=paste0("raw_", names(raw.dfs[i]),".csv"), quote = "auto")
}

# save answer to file

fwrite(q1,file="q1.csv", quote = "auto")

# remove objects after saving

rm(list = ls())
