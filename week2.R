# Global options
options(stringsAsFactors = FALSE)
setwd(dirname(parent.frame(2)$ofile))

# load libraries
library(tm)
library(RCurl)
library(tidyverse)
library(tidytext)
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
  lines$line = seq(1, nrow(lines), 1)
  lines <- lines %>% select(line, text)
  return(lines)
}



# create line dfs with word counts
blog.df <- getData(files[1])
news.df <- getData(files[2])
twitter.df <- getData(files[3])


# create tidy tokenized df (filter out numbers)
tidy.blog <- blog.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word))
  
tidy.news <- news.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word))

tidy.twitter <- twitter.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word))


# strip stopwords and profanities
prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"
# get text from url
prof_file <- getURL(prof_url, ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)
# create profanity stopword character list
prof_stopwords <- unlist(strsplit(prof_file, "\n"))
# Create full stopwords list, including profanity terms
custom_stopwords <- data_frame(
  word = c(stopwords("english"), prof_stopwords),
  lexicon = "custom"
)
data(stop_words)
custom_stopwords <- rbind(stop_words, custom_stopwords)

# strip stopwords & profanities
tidy.blog <- tidy.blog %>%
  anti_join(custom_stopwords)
tidy.news <- tidy.news %>%
  anti_join(custom_stopwords)
tidy.twitter <- tidy.twitter %>%
  anti_join(custom_stopwords)

### EXPLORATORY DATA ANALYSIS

## Document-type analysis

# Q1. Which text source is, on average, the longest format? The shortest?

blog.docs <- blog.df %>%
  mutate(char_count = nchar(text)) %>%
  select(line, text, char_count)
blog.avg.char <- mean(blog.docs$char_count)

news.docs <- news.df %>%
  mutate(char_count = nchar(text)) %>%
  select(line, text, char_count)
news.avg.char <- mean(news.docs$char_count)

twitter.docs <- twitter.df %>%
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

# show plots side by side
grid.arrange(p1, p2, p3, p4, p5, p6, ncol=2)

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

# Answer: Yes, according to the KW test, they are significantly different in length.

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
q4.max

q4.min <- total.words[which.min(total.words)]
q4.min

# Q5. Some words are more frequent than others - what are the distributions of word frequencies?

# Generate word cloud: Blog
png("output/blog_wordcloud.png", width=1280,height=800)
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
dev.off()


# Generate word cloud: News
png("output/news_wordcloud.png", width=1280,height=800)
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
dev.off()

# Generate word cloud: Twitter
png("output/twitter_wordcloud.png", width=1280,height=800)
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
dev.off()

# which words are common to all 3 sources?

common_blog_news <- inner_join(blog.freq, news.freq, by = "word")
common_news_twitter <- inner_join(news.freq, twitter.freq, by = "word")
common_twitter_blog <- inner_join(twitter.freq, blog.freq, by = "word")
common_full <- inner_join(common_blog_news, common_news_twitter, by = "word")

all.freq <- bind_rows(mutate(tidy.blog, source = "blog"),
                      mutate(tidy.news, source = "news"),
                      mutate(tidy.twitter, source = "twitter")) %>%
  count(source, word) %>%
  group_by(source) %>%
  mutate(proportion = n / sum(n)) %>%
  select(-n) %>%
  spread(source, proportion) %>% # spread groups across columns
  gather(source, proportion, "news":"twitter")

# Visualization of word frequency similarity between sources
library(scales)

p8 <- ggplot(all.freq, aes(x = proportion, y = blog, color = blog- proportion)) +
  geom_abline(color = "gray40", lty = 2) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  scale_color_gradient(limits = c(0, 0.001), low = "darkslategray4", high = "gray75") +
  facet_wrap(~source, ncol = 2) +
  theme(legend.position="none") +
  labs(y = "blog", x = NULL)
p8 

# Statistical test of word frequency similarity between sources

# blog vs news

cor.test(data = filter(all.freq, all.freq$source == "news"), ~ proportion + blog)

# Answer: significant level of correlation, about 50% similar

# similarity between blog & twitter

cor.test(data = filter(all.freq, all.freq$source == "twitter"), ~ proportion + blog)

# Answer: significant level of correlation, about 60% similar

# Q6. What are the frequencies of 2-grams and 3-grams in the dataset?

# Tokenize by 2-grams

bigrams.blog <- blog.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  # split to find stopword-based ngrams
  separate(bigram, c("word1","word2"), sep = " ") %>%
  # remove number-based entries
  filter(!grepl("[0-9]+", word1)) %>%
  filter(!grepl("[0-9]+", word2)) %>%
  # filter out ngrams with stopwords in them
  filter(!(word1 %in% custom_stopwords$word|word2 %in% custom_stopwords$word))

bigrams.news <- news.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  # split to find stopword-based ngrams
  separate(bigram, c("word1","word2"), sep = " ") %>%
  # remove number-based entries
  filter(!grepl("[0-9]+", word1)) %>%
  filter(!grepl("[0-9]+", word2)) %>%
  # filter out ngrams with stopwords in them
  filter(!(word1 %in% custom_stopwords$word|word2 %in% custom_stopwords$word))

bigrams.twitter <- twitter.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  # split to find stopword-based ngrams
  separate(bigram, c("word1","word2"), sep = " ") %>%
  # remove number-based entries
  filter(!grepl("[0-9]+", word1)) %>%
  filter(!grepl("[0-9]+", word2)) %>%
  # filter out ngrams with stopwords in them
  filter(!(word1 %in% custom_stopwords$word|word2 %in% custom_stopwords$word))



# Tokenize by 3-grams

trigrams.blog <- blog.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE) %>%
  # split to find stopword-based ngrams
  separate(trigram, c("word1","word2", "word3"), sep = " ") %>%
  # remove number-based entries
  filter(!grepl("[0-9]+", word1)) %>%
  filter(!grepl("[0-9]+", word2)) %>%
  filter(!grepl("[0-9]+", word3)) %>%
  # filter out ngrams with stopwords in them
  filter(!(word1 %in% custom_stopwords$word|word2 %in% custom_stopwords$word|word3 %in% custom_stopwords$word))

trigrams.news <- news.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE)

trigrams.twitter <- twitter.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE)



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

