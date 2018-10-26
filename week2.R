# Global options
options(stringsAsFactors = FALSE)
setwd(dirname(parent.frame(2)$ofile))

# load libraries
library(tm)
library(dplyr)
library(RCurl)

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
  # open file connection
  con <- file(file, open="r")
  # read in all lines
  lines <- as.data.frame(readLines(con, n, warn = FALSE))
  names(lines) <- c("text")
  #close connection
  close(con)
  return(lines)
}

# write sample lists to corpora
createCorpus <- function(text.df) {
  # create doc_id column
  text.df$doc_id <- seq(1, nrow(text.df), 1)
  corpus <- Corpus(DataframeSource(text.df))
  return(corpus)
}

# Create a profanity filter using the english and international files here:

# get profanity lists
prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"

# get text from urls
prof_file <- getURL("https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt", ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)

prof_stopwords <- unlist(strsplit(prof_file, "\n"))

# Create full stopwords list, including profanity terms
custom_stopwords <- c(stopwords("english"), prof_stopwords)

# Write function that cleans and tokenizes lines of text
cleanString <- function(corpus) {
  # lowercase
  corpus <- tm_map(corpus, content_transformer(tolower))
  # remove punctuation
  corpus <- tm_map(corpus, FUN = removePunctuation)
  # remove numbers
  corpus <- tm_map(corpus, FUN = removeNumbers)
  # strip whitespace
  corpus <- tm_map(corpus, FUN = stripWhitespace)
  # remove stopwords
  # corpus <- tm_map(corpus, removeWords, custom_stopwords)
  return(corpus)
}

# Get data
blog <- getData(files[1])
news <- getData(files[2])
twitter <- getData(files[3])

# Create corpuses
blog_corp <- createCorpus(blog)
news_corp <- createCorpus(news)
twitter_corp <- createCorpus(twitter)

# clean each sample corpus (no stopword removal)

clean_blog <- cleanString(blog_corp)
# clean_news <- cleanString(news_corp)
# clean_twitter <- cleanString(twitter_corp)


# create TDM
# blog_dtm <- DocumentTermMatrix(clean_blog)
# news_dtm <- DocumentTermMatrix(clean_news)
# twitter_dtm <- DocumentTermMatrix(clean_twitter)

# Tasks to accomplish

# 1. Exploratory analysis - perform a thorough exploratory analysis of the data, understanding the distribution of words and relationship between the words in the corpora.

# Get total number of unique terms in each corpus 
# total.words <- list(
#   "blog" = dim(blog_dtm)[[2]],
#   "twitter" = dim(twitter_dtm)[[2]],
#   "news" = dim(news_dtm)[[2]]
# )

# Q1. Which text source has HIGHEST word diversity (most # of words)? What about the LOWEST? 
# q1.max <- total.words[which.max(total.words)]
# q1.max
# 
# q1.min <- total.words[which.min(total.words)]
# q1.min

# Q2. Which text source is, on average, the longest format by word count? The shortest?




# What is the distribution of terms in each 


# 2. Understand frequencies of words and word pairs - build figures and tables to understand variation in the frequencies of words and word pairs in the data.
# Questions to consider
# 
# Some words are more frequent than others - what are the distributions of word frequencies?
# What are the frequencies of 2-grams and 3-grams in the dataset?
# How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?
# How do you evaluate how many of the words come from foreign languages?
# Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?