# Global options
options(stringsAsFactors = FALSE)
setwd(dirname(parent.frame(2)$ofile))

# load libraries
library(tm)
# library(RWeka)
# look into this: https://datascience.stackexchange.com/questions/18522/text-mining-in-r-without-rweka
library(RCurl)
library(tidyverse)
#install dev version of ggplot2 to get stat_qq_line function
devtools::install_github("tidyverse/ggplot2")
library(ggplot2)
library(gridExtra)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(ggpubr)

# download dataset from URL
url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
destfile <- "./input/capstone-data.zip"

download.file(url, destfile)
unzip(destfile, exdir ="./input/")
#remove zip file
file.remove(destfile)
# create paths to each data file
file_dir <- paste(getwd(),"input/final/en_US", sep="/")
files <- list.files(file_dir, full.names = TRUE)


# get the number of lines in file
getTotalLines <- function(file) {
  com <- paste0("wc -l ", file, " | awk '{ print $1 }'")
  n <- as.numeric(system(command=com, intern=TRUE))
  return(n)    
}

# read in text from files
getData <- function(file) {
  # get the number of lines in file
  n <- getTotalLines(file)
  # uncomment line 35 if you want only a small sample of lines
  n <- n*0.001
  # open file connection
  con <- file(file, open="r")
  # read in all lines
  lines <- as.data.frame(readLines(con, n, warn = FALSE))
  names(lines) <- c("text")
  #close connection
  close(con)
  lines$doc_id = seq(1, nrow(lines), 1)
  df <- lines %>%
    mutate(char_count = nchar(text)) %>%
    select(doc_id, text, char_count)
  return(df)
}


# write sample lists to corpora
createCorpus <- function(text.df) {
  # create doc_id column
  corpus <- Corpus(DataframeSource(text.df))
  return(corpus)
}


# Write function that cleans and tokenizes lines of text
cleanString <- function(corpus) {
  # get profanity lists
  prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"
  # get text from urls
  prof_file <- getURL(prof_url, ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)
  # create profane stopword character list
  prof_stopwords <- unlist(strsplit(prof_file, "\n"))
  
  # Create full stopwords list, including profanity terms
  custom_stopwords <- c(stopwords("english"), prof_stopwords)
  # lowercase
  corpus <- tm_map(corpus, content_transformer(tolower))
  #create toSpace content transformer to deal with hyphen/colon issues
  toSpace <- content_transformer(function(x, pattern) {return (gsub(pattern, " ", x))})
  corpus <- tm_map(corpus, toSpace, "-")
  corpus <- tm_map(corpus, toSpace, ":")
  corpus <- tm_map(corpus, toSpace, "’")
  corpus <- tm_map(corpus, toSpace, "‘")
  corpus <- tm_map(corpus, toSpace, "“")
  corpus <- tm_map(corpus, toSpace, "”")
  #corpus <- tm_map(corpus, toSpace, "—")
  #corpus <- tm_map(corpus, toSpace, " -")
  
  # remove punctuation
  corpus <- tm_map(corpus, FUN = removePunctuation)
  # remove numbers
  corpus <- tm_map(corpus, FUN = removeNumbers)
  # strip whitespace
  corpus <- tm_map(corpus, FUN = stripWhitespace)
  # remove stopwords
  corpus <- tm_map(corpus, removeWords, custom_stopwords)
  return(corpus)
  # stem document
  corpus <- tm_map(corpus, stemDocument)
}


# create line dfs with word counts
blog.df <- getData(files[1])
news.df <- getData(files[2])
twitter.df <- getData(files[3])

# create corpuses
blog.corp <- createCorpus(blog.df)
news.corp <- createCorpus(news.df)
twitter.corp <- createCorpus(twitter.df)

# clean each sample corpus
system.time(blog.corp <- cleanString(blog.corp))
system.time(news.corp <- cleanString(news.corp))
system.time(twitter.corp <- cleanString(twitter.corp))

# create TDM
blog.dtm <- DocumentTermMatrix(blog.corp)
news.dtm <- DocumentTermMatrix(news.corp)
twitter.dtm <- DocumentTermMatrix(twitter.corp)

### EXPLORATORY DATA ANALYSIS

## Document-type analysis

# Q1. Which text source is, on average, the longest format? The shortest?

blog.avg.char <- mean(blog.df$char_count)
news.avg.char <- mean(news.df$char_count)
twitter.avg.char <- mean(twitter.df$char_count)

mean.doc.length <- list(
  "blog" = blog.avg.char,
  "news" = news.avg.char,
  "twitter" = twitter.avg.char
)

q1.max <- mean.doc.length[which.max(mean.doc.length)]
q1.min <- mean.doc.length[which.min(mean.doc.length)]

# Q2. Are these document lengths normally distributed?

# blog histogram  
p1 <- ggplot(data = blog.df, aes(char_count)) 
p1 <- p1 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(blog.df$char_count), color="red")
p1 <- p1 + ggtitle("blog document length: histogram")

# blog qqplot
p2 <- ggplot(data = blog.df, aes(sample = char_count))
p2 <- p2 + stat_qq() + stat_qq_line()
p2 <- p2 + ggtitle("blog document length: qq-plot")

# news histogram 
p3 <- ggplot(data = news.df, aes(char_count)) 
p3 <- p3 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(news.df$char_count), color="red")
p3 <- p3 + ggtitle("news document length: histogram")

# news qqplot
p4 <- ggplot(data = news.df, aes(sample = char_count))
p4 <- p4 + stat_qq() + stat_qq_line()
p4 <- p4 + ggtitle("news document length: qq-plot")

# twitter histogram  
p5 <- ggplot(data = twitter.df, aes(char_count)) 
p5 <- p5 + geom_histogram(bins = 50) + geom_vline(xintercept=mean(twitter.df$char_count), color="red")
p5 <- p5 + ggtitle("twitter document length: histogram")

# twitter qqplot
p6 <- ggplot(data = twitter.df, aes(sample = char_count))
p6 <- p6 + stat_qq() + stat_qq_line()
p6 <- p6 + ggtitle("twitter document length: qq-plot")

# show plots side by side
grid.arrange(p1, p2, p3, p4, p5, p6, ncol=2)

# Q3. Are the different sources *significantly* different in length? 

blog.df <- blog.df %>%
  mutate(type = "blog")

news.df <- news.df %>%
  mutate(type = "news")

twitter.df <- twitter.df %>%
  mutate(type = "twitter")

KWdata <- rbind(blog.df, news.df, twitter.df)
KWdata$type = as.factor(KWdata$type)

# Visualize the 3 groups using a boxplot:

p7 <- ggplot(data = KWdata, aes(type, char_count))
p7 <- p7 + geom_boxplot() 
p7

# Run a test to be sure:
kruskal.test(KWdata$char_count, KWdata$type)

# Answer - yes, according to the KW test, they are significantly different in length.

# Q4. Which text source has HIGHEST word diversity (most # of words)? What about the LOWEST? 

# Get total number of unique terms in each corpus 
total.words <- list(
  "blog" = dim(blog.dtm)[[2]],
  "twitter" = dim(twitter.dtm)[[2]],
  "news" = dim(news.dtm)[[2]]
)

q4.max <- total.words[which.max(total.words)]
q4.max

q4.min <- total.words[which.min(total.words)]
q4.min


### Term Frequency Analysis  ###

# Q5. Some words are more frequent than others - what are the distributions of word frequencies?

# Create sorted dataframes (for word clouds)
by_freq <- function(dtm) {
  freq <- colSums(as.matrix(dtm))
  desc <- sort(freq, decreasing = TRUE)
  word.freq.df <- data.frame(
    word = names(desc),
    freq = desc
  )
  return(word.freq.df)
}

# Generate word cloud: Blog
blog_freq <- by_freq(blog.dtm)
png("output/blog_wordcloud.png", width=1280,height=800)
wordcloud(
  blog_freq$word, 
  blog_freq$freq,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Blues")
  )
dev.off()


# Generate word cloud: News
news_freq <- by_freq(news.dtm)
png("output/news_wordcloud.png", width=1280,height=800)
wordcloud(
  news_freq$word, 
  news_freq$freq,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Reds")
)
dev.off()

# Generate word cloud: Twitter
twitter_freq <- by_freq(twitter.dtm)
png("output/twitter_wordcloud.png", width=1280,height=800)
wordcloud(
  twitter_freq$word, 
  twitter_freq$freq,
  scale=c(8,.3),
  min.freq = 1, 
  max.words = 1000, 
  random.order=FALSE, 
  random.color = FALSE, 
  rot.per=0.15, 
  colors=brewer.pal(12, "Greens")
)
dev.off()

# Compare top 25 most frequent terms for each source

top25terms_blog <- head(blog_freq, 25)
top25terms_news <- head(news_freq, 25)
top25terms_twitter <- head(twitter_freq, 25)

# Create bar graphs

# blog
top25terms_blog_plot <- ggplot(top25terms_blog, aes(x = reorder(word, -freq), y = freq)) + 
  geom_col(fill = "#3182bd") +
  labs(x = "\nWord", y = "Count\n") +
  ylim(0, 300) +
  # add title
  ggtitle("Top 25 Most Frequent Words in the Blog Corpus\n") +
  # center it 
  theme(plot.title = element_text(hjust = 0.5), 
        plot.margin=unit(c(1,1,1.5,1.2),"cm")
        ) + 
  # add data labels
  geom_text(aes(label=freq), position=position_dodge(width=0.9), vjust=-0.25)
top25terms_blog_plot



# news
top25terms_news_plot <- ggplot(top25terms_news, aes(x = reorder(word, -freq), y = freq)) + 
  geom_col(fill = "#de2d26") +
  labs(x = "\nWord", y = "Count\n") +
  ylim(0, 300) +
  # add title
  ggtitle("Top 25 Most Frequent Words in the News Corpus\n") +
  # center it 
  theme(
    plot.title = element_text(hjust = 0.5), 
    plot.margin=unit(c(1,1,1.5,1.2),"cm")
    ) + 
  # add data labels
  geom_text(aes(label=freq), position=position_dodge(width=0.9), vjust=-0.25)
top25terms_news_plot


# twitter
top25terms_twitter_plot <- ggplot(top25terms_twitter, aes(x = reorder(word, -freq), y = freq)) + 
  geom_col(fill = "#31a354") +
  labs(x = "\nWord", y = "Count\n") +
  ylim(0, 300) +
  # add title
  ggtitle("Top 25 Most Frequent Words in the Twitter Corpus\n") +
  # center it 
  theme(plot.title = element_text(hjust = 0.5), 
        plot.margin=unit(c(1,1,1.5,1.2),"cm")
        ) + 
  # add data labels
  geom_text(aes(label=freq), position=position_dodge(width=0.9), vjust=-0.25)
top25terms_twitter_plot

ggarrange(
  top25terms_blog_plot,
  top25terms_news_plot,
  top25terms_twitter_plot, 
  ncol = 1, 
  nrow = 3
)

# Q6. What are the frequencies of 2-grams and 3-grams in the dataset?

# Q7. How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?

# Q8. How do you evaluate how many of the words come from foreign languages?

# Q9. Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?



### MODELLING

# Tasks to accomplish

# Build basic n-gram model - using the exploratory analysis you performed, build a basic n-gram model for predicting the next word based on the previous 1, 2, or 3 words.
# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.
# Questions to consider
# 
# How can you efficiently store an n-gram model (think Markov Chains)?
# How can you use the knowledge about word frequencies to make your model smaller and more efficient?
# How many parameters do you need (i.e. how big is n in your n-gram model)?
# Can you think of simple ways to "smooth" the probabilities (think about giving all n-grams a non-zero probability even if they aren't observed in the data) ?
# How do you evaluate whether your model is any good?
# How can you use backoff models to estimate the probability of unobserved n-grams?

