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
library(LaF)


options <- list("0", "1", "2", "3","4", "5", "6","7","8", "9", "10")

program <- readline(prompt="What program would you like to run?")
program <- as.integer(program)

if (program == 0) {
 source('cleantexttidy.R', echo=TRUE)
} else if (program == 1) {
  source('week2q1.R', echo=TRUE)
} else if (program == 2) {
  source('week2q2.R', echo=TRUE)
} else if (program == 3) {
  source('week2q3.R', echo=TRUE)
} else if (program == 4) {
  source('week2q4.R', echo=TRUE)
} else if (program == 5) {
  source('week2q5.R', echo=TRUE)
} else if (program == 6) {
  source('week2q6.R', echo=TRUE)
} else if (program == 7) {
  source('week2q7.R', echo=TRUE)
} else if (program == 8) {
  source('week2q8.R', echo=TRUE)
} else if (program == 9) {
  source('week2q9.R', echo=TRUE)
} else if (program == 10) {
  source('ngramnodel.R', echo=TRUE)
} else {
  print("sorry, no match")
}





# # Q3. Are the different sources *significantly* different in length? 
# source('week2q3.R')
# p7
# # Run a test to be sure:
# kruskal.test(KWdata$char_count, KWdata$type)
# print("Answer: Yes, according to the KW test, they are significantly different in length.")
# 
# # Q4. Which text source has HIGHEST word diversity (most # of words)? What about the LOWEST? 
# 
# # Get total number of unique terms in each corpus 
# 
# source('week2q4.R')
# print(paste("The highest diversity format is:", q4.max))
# print(paste("The lowest diversity format is:", q4.min))
# 
# 
# ## TERM-LEVEL DATA ANALYSIS
# 
# # Q5. Some words are more frequent than others - what are the distributions of word frequencies?
# 
# source('week2q5.R')
# 
# # Q6. Which words are common to all 3 sources?
# 
# source('week2q6.R')
# print(paste("The terms common to all sources are shown in the following table: "))
# 
# common_full
# 
# # Visualization of term similarity between sources:
# print(paste("Compare term similarity across sources via the following visualization: "))
# 
# p8 
# 
# # Statistical tests of word frequency similarity between sources:
# 
# 
# # blog vs news
# cor.test(data = filter(all.freq, all.freq$source == "news"), ~ proportion + blog)
# print(paste("There is a significant level of correlation between news and blog content, about 50% correlation."))
# 
# # blog vs twitter
# cor.test(data = filter(all.freq, all.freq$source == "twitter"), ~ proportion + blog)
# print(paste("There is a significant level of correlation between twitter and blog content, about 60% correlation."))
# 
# 
# # Q7. What are the frequencies of 2-grams and 3-grams in the dataset?
# 
# source("week2q7.R")
# 
# print(paste("Blog bigrams:"))
# bigrams.blog
# print(paste("News bigrams:"))
# bigrams.news
# print(paste("Twitter bigrams:"))
# bigrams.twitter
# 
# print(paste("Blog trigrams:"))
# trigrams.blog
# print(paste("News trigrams:"))
# trigrams.news
# print(paste("Twitter trigrams:"))
# trigrams.twitter
# 
# # Q8. How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?
# 
# source("week2q8.R")
# 
# setCoverage(all.freq, 0.5)
# setCoverage(all.freq, 0.9)
# 
# 
# # Q9. How do you evaluate how many of the words come from foreign languages?
# 
# source("week2q9.R")
# 
# 
# # Q9. Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?
# 
# 
# 
# ### MODELLING
# 
# # Tasks to accomplish
# 
# # Build basic n-gram model - using the exploratory analysis you performed, build a basic n-gram model for predicting the next word based on the previous 1, 2, or 3 words.

#source("ngrammodel.R", echo=TRUE)




# # Questions to consider
# # 
# # How can you efficiently store an n-gram model (think Markov Chains)?
# 
# # How can you use the knowledge about word frequencies to make your model smaller and more efficient?
# 
# # How many parameters do you need (i.e. how big is n in your n-gram model)?
# 
# # Can you think of simple ways to "smooth" the probabilities (think about giving all n-grams a non-zero probability even if they aren't observed in the data) ?
# 
# # How do you evaluate whether your model is any good?
# 
# # How can you use backoff models to estimate the probability of unobserved n-grams?
# 
