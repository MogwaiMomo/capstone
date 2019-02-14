# Q2. Are these document lengths normally distributed?


# blog histogram  
p1 <- ggplot(data = blog.docs, aes(char_count)) 
p1 <- p1 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(blog.docs$char_count), color="red")
p1 <- p1 + ggtitle("blog document length: histogram") + xlab("char. length") + ylab("# docs")

# blog qqplot
p2 <- ggplot(data = blog.docs, aes(sample = char_count))
p2 <- p2 + stat_qq() + stat_qq_line()
p2 <- p2 + ggtitle("blog document length: qq-plot")

# news histogram 
p3 <- ggplot(data = news.docs, aes(char_count)) 
p3 <- p3 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(news.docs$char_count), color="red")
p3 <- p3 + ggtitle("news document length: histogram") + xlab("char. length") + ylab("# docs")

# news qqplot
p4 <- ggplot(data = news.docs, aes(sample = char_count))
p4 <- p4 + stat_qq() + stat_qq_line()
p4 <- p4 + ggtitle("news document length: qq-plot") 

# twitter histogram  
p5 <- ggplot(data = twitter.docs, aes(char_count)) 
p5 <- p5 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(twitter.docs$char_count), color="red")
p5 <- p5 + ggtitle("twitter document length: histogram") + xlab("char. length") + ylab("# docs")

# twitter qqplot
p6 <- ggplot(data = twitter.docs, aes(sample = char_count))
p6 <- p6 + stat_qq() + stat_qq_line()
p6 <- p6 + ggtitle("twitter document length: qq-plot")

grid.arrange(p1, p2, p3, p4, p5, p6, ncol=2)
print(paste("None of the document lengths look normally distributed."))
