# # Q7. What are the frequencies of 2-grams and 3-grams in the dataset?

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