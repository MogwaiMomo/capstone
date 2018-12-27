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
library(textstem)
library(scales)
library(wordnet)
library(RDRPOSTagger)



### EXPLORATORY DATA ANALYSIS

# Clean the data using tidy methods:

source('cleantexttidy.R')

## SOURCE-LEVEL DATA ANALYSIS

# Q1. Which text source is, on average, the longest format? The shortest?

source('week2q1.R')
print(paste("The longest format is:", q1.max))
print(paste("The shortest format is:", q1.min))


# Q2. Are these document lengths normally distributed?

# show plots side by side
source('week2q2.R')
grid.arrange(p1, p2, p3, p4, p5, p6, ncol=2)
print(paste("None of the document lengths look normally distributed."))

# Q3. Are the different sources *significantly* different in length? 
source('week2q3.R')
p7
# Run a test to be sure:
kruskal.test(KWdata$char_count, KWdata$type)
print("Answer: Yes, according to the KW test, they are significantly different in length.")

# Q4. Which text source has HIGHEST word diversity (most # of words)? What about the LOWEST? 

# Get total number of unique terms in each corpus 

source('week2q4.R')
print(paste("The highest diversity format is:", q4.max))
print(paste("The lowest diversity format is:", q4.min))


## TERM-LEVEL DATA ANALYSIS

# Q5. Some words are more frequent than others - what are the distributions of word frequencies?

source('week2q5.R')

# Q6. Which words are common to all 3 sources?

source('week2q6.R')
print(paste("The terms common to all sources are shown in the following table: "))

common_full

# Visualization of term similarity between sources:
print(paste("Compare term similarity across sources via the following visualization: "))

p8 

# Statistical tests of word frequency similarity between sources:


# blog vs news
cor.test(data = filter(all.freq, all.freq$source == "news"), ~ proportion + blog)
print(paste("There is a significant level of correlation between news and blog content, about 50% correlation."))

# blog vs twitter
cor.test(data = filter(all.freq, all.freq$source == "twitter"), ~ proportion + blog)
print(paste("There is a significant level of correlation between twitter and blog content, about 60% correlation."))


# Q7. What are the frequencies of 2-grams and 3-grams in the dataset?

source("week2q7.R")

print(paste("Blog bigrams:"))
bigrams.blog
print(paste("News bigrams:"))
bigrams.news
print(paste("Twitter bigrams:"))
bigrams.twitter

print(paste("Blog trigrams:"))
trigrams.blog
print(paste("News trigrams:"))
trigrams.news
print(paste("Twitter trigrams:"))
trigrams.twitter

# Q8. How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?

source("week2q8.R")

setCoverage(all.freq, 0.5)
setCoverage(all.freq, 0.9)


# Q8. How do you evaluate how many of the words come from foreign languages?

# METHOD 1: Using Google's CLD3 package (language detection)

library(cld3)

# Create a test df with 3 different languages

# Get data from other langs 
file_dir_de <- paste(getwd(),"input/final/de_DE", sep="/")
file_dir_fi <- paste(getwd(),"input/final/fi_FI", sep="/")
file_dir_ru <- paste(getwd(),"input/final/ru_RU", sep="/")


files_de <- list.files(file_dir_de, full.names = TRUE)
files_fi <- list.files(file_dir_fi, full.names = TRUE)
files_ru <- list.files(file_dir_ru, full.names = TRUE)


# read in text from files
raw.de.blog.df <- getData(files_de[1])
raw.fi.blog.df <- getData(files_fi[1])
raw.ru.blog.df <- getData(files_ru[1])

# create test df using random selection
create_multilang_df <- function(y) {
  df <- data.frame(
    line = NULL,
    text = NULL
  )
  for (n in 1:y) {
    print(n)
    # draw a random number between 0 and 1
    i <- runif(1, min = 0, max = 1)
    # if i is between 0 and 0.25, english
    if (i < 0.25) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.blog.df)))
      df <- rbind(df, raw.blog.df[row,])
    }
    # if i is between 0.25 and 0.5, german
    else if (i >= 0.25 && i < 0.5) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.de.blog.df)))
      df <- rbind(df, raw.de.blog.df[row,])
    }
    # if i is between 0.5 and 0.75, finnish
    else if (i >= 0.5 && i < 0.75) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.fi.blog.df)))
      df <- rbind(df, raw.fi.blog.df[row,])
    }
    # if i is between 0.75 and 1, russian
    else {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.ru.blog.df)))
      df <- rbind(df, raw.ru.blog.df[row,])
    }
  }
  return(df)
}
  

test.df <- create_multilang_df(100)

# try it using lapply
test.df$lang <- lapply(test.df$text, detect_language)



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

