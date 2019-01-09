# General methodology: Treat every token as a state and predict the next word based on the previous state.

# helpful references:
# https://datawarrior.wordpress.com/2018/01/22/document-term-matrix-text-mining-in-r-and-python/
# https://cran.r-project.org/web/packages/textmineR/vignettes/a_start_here.html
# https://youtu.be/w4utWoJfxGE?t=269

# load textmineR package
library(textmineR)


training_data <- blog.docs %>% # NOT lemmatized
  select(doc_id = line, text)

#### N-GRAM MODEL FOR WORD PREDICTION

train_model <- function(text_vector) {
  dtm <- CreateDtm(text_vector,
                   #doc_names = training_data$doc_id,
                   ngram_window = c(1, 3),
                   lower = TRUE,
                   remove_punctuation = TRUE,
                   remove_numbers = TRUE,
                   stopword_vec = NULL # don't remove stopwords!
                   #stem_lemma_function = wordStem
  )
  
  # get term frequency for the dtm
  tf_matrix <- TermDocFreq(dtm = dtm)
  tf_matrix <- tf_matrix[order(tf_matrix$term_freq, decreasing = TRUE), ]
  
  # bigram freq table
  tf_bigrams <- tf_matrix %>%
    filter(grepl("_", term)) %>%
    filter(!grepl("_.+_", term)) %>%
    select(term, term_freq) %>%
    rename(bigram = term, bigram_count = term_freq) %>%
    # add column of what the first word is
    mutate(tmp = bigram) %>%
    separate(tmp, c("unigram", "unigram2"))
  
  # add column of count of first word (grab from unigram list)
  tf_bigrams <- left_join(tf_bigrams, tf_unigrams, by = "unigram")
  tf_transprob <- tf_bigrams %>%
    # remember: bigram prob = P(w2|w1)  
    mutate(bigram_prob = bigram_count / unigram_count)
  
  bigram_model <- data.frame(
    w1 = tf_transprob$unigram,
    w2 =  tf_transprob$unigram2,
    prob = tf_transprob$bigram_prob
  ) %>%
    group_by(w1) %>%
    arrange(desc(prob), .by_group = TRUE)
  rm(tf_transprob, tf_bigrams, dtm, tf_matrix)
  return(bigram_model)
}

trans_df <- train_model(training_data$text)


# test Markov model


# Also look into: https://cran.r-project.org/web/packages/markovchain/markovchain.pdf


# Will use 10-fold cross validation for test-error estimation. Train the data on the blog text. (Look into Caret package and 'cv' options for this.)


# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.