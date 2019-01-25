# General methodology: Treat every token as a state and predict the next word based on the previous state.

# helpful references:
# https://datawarrior.wordpress.com/2018/01/22/document-term-matrix-text-mining-in-r-and-python/
# https://cran.r-project.org/web/packages/textmineR/vignettes/a_start_here.html
# https://youtu.be/w4utWoJfxGE?t=269
# https://github.com/ashwinmj/word-prediction/blob/master/MarkovModel.ipynb

# load textmineR package
library(textmineR)

createTrainingData <- function(file) {
  training.dfs <- list()
  for (i in 1:9) {
    df <- getRandomDataFast(file)
    item <- paste("training", i, sep="_")
    training.dfs[[item]] <- df
  }
  return(training.dfs)
} 

trainingDatasets <- createTrainingData(files[4])
testDataset <- getRandomDataFast(files[4])


#### N-GRAM MODEL FOR WORD PREDICTION

train_model <- function(df) {
  dtm <- CreateDtm(df$text,
                   doc_names = training_data$doc_id,
                   ngram_window = c(1, 3),
                   lower = TRUE,
                   remove_punctuation = TRUE,
                   remove_numbers = TRUE,
                   stopword_vec = NULL # don't remove stopwords!
                   #stem_lemma_function = wordStem
  )
  
  # get term frequency for the dtm
  tf_matrix <- TermDocFreq(dtm = dtm)
  tf_matrix <- tf_matrix[order(tf_matrix$term_freq, decreasing = TRUE),]
  
  # w1 freq table
  w1_tf <- tf_matrix %>%
    filter(!grepl("_", term)) %>%
    select(w1 = term, w1_count = term_freq)

  # w1_w2 freq table
  w1_w2_tf <- tf_matrix %>%
    filter(grepl("_", term)) %>%
    filter(!grepl("_.+_", term)) %>%
    select(term, term_freq) %>%
    rename(w1_w2 = term, w1_w2_count = term_freq) %>%
    # add column of what the first word is
    mutate(tmp = w1_w2) %>%
    separate(tmp, c("w1", "w2"))
  
    # add column of count of first word (grab from unigram list)
    w1_w2_tf <- left_join(w1_w2_tf, w1_tf, by = "w1")
    w1_w2_prob <- w1_w2_tf %>%
      # remember: bigram prob = P(w2|w1)
      mutate(trans_prob = w1_w2_count / w1_count) %>%
        group_by(w1) %>%
        arrange(desc(trans_prob), .by_group = TRUE)

  return(w1_w2_prob)
}

model <- train_model(testDataset)


# create test of Markov model

test_model <- function(unigram, model) {
  w <- as.character(unigram)
  if (w %in% model$w1) {
    next_w <- model %>%
      filter(w == w1) %>%
      select(w2, trans_prob) 
    print(next_w)
  }
  else {
    print("Word not found.")
  }
}


# Also look into: https://cran.r-project.org/web/packages/markovchain/markovchain.pdf




# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.