# Q3. Are the different sources *significantly* different in length? 



blog.docs <- blog.docs %>%
  mutate(type = "blog")

news.docs <- news.docs %>%
  mutate(type = "news")

twitter.docs <- twitter.docs %>%
  mutate(type = "twitter")

KWdata <- rbind(blog.docs, news.docs, twitter.docs)
KWdata$type = as.factor(KWdata$type)

# Visualize the 3 groups using a boxplot:

p7 <- ggplot(data = KWdata, aes(type, char_count))
p7 <- p7 + geom_boxplot() 
p7

# Run a test to be sure:
kruskal.test(KWdata$char_count, KWdata$type)
print("Answer: Yes, according to the KW test, they are significantly different in length.")