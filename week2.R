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
# news.df <- getData(files[2])
# twitter.df <- getData(files[3])


# create tidy tokenized df
tidy.blog <- blog.df %>%
  unnest_tokens(word, text)

# strip stopwords and profanities

# get profanity list
prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"
# get text from urls
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

### EXPLORATORY DATA ANALYSIS: TIDY N-GRAM ANALYSIS


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

