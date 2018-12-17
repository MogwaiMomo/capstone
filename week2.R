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
# library(RDRPOSTagger) # rJava bug :/
source('cleantexttidy.R')


### EXPLORATORY DATA ANALYSIS

## Source-level analysis:

# Q1. Which text source is, on average, the longest format? The shortest?

source('week2q1.R')
print(paste("The longest format is:", q1.max, "\n"))
print(paste("The shortest format is:", q1.min, "\n"))


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
print(paste("The highest diversity format is:", q4.max, "\n"))
print(paste("The lowest diversity format is:", q4.min, "\n"))


# Q5. Some words are more frequent than others - what are the distributions of word frequencies?

source('week2q5.R')

# Q6. Which words are common to all 3 sources?


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

bigrams.blog <- clean.blog.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  filter(!is.na(bigram))

bigrams.news <- clean.news.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  filter(!is.na(bigram))

bigrams.twitter <- clean.twitter.df %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
  count(bigram, sort = TRUE) %>%
  filter(!is.na(bigram))



# Tokenize by 3-grams

trigrams.blog <- clean.blog.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE) %>%
  filter(!is.na(trigram))

trigrams.news <- clean.news.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE) %>%
  filter(!is.na(trigram))

trigrams.twitter <- clean.twitter.df %>%
  unnest_tokens(trigram, text, token = "ngrams", n = 3) %>%
  count(trigram, sort = TRUE) %>%
  filter(!is.na(trigram))

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

