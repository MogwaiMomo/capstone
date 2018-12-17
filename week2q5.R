# Generate word cloud: Blog
# png("output/blog_wordcloud.png", width=1280,height=800)
wordcloud(
  blog.freq$word, 
  blog.freq$n,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Blues")
)
# dev.off()

# Generate word cloud: News
# png("output/news_wordcloud.png", width=1280,height=800)
wordcloud(
  news.freq$word, 
  news.freq$n,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Reds")
)
#dev.off()

# Generate word cloud: Twitter
# png("output/twitter_wordcloud.png", width=1280,height=800)
wordcloud(
  twitter.freq$word, 
  twitter.freq$n,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Greens")
)
# dev.off()