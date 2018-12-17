
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