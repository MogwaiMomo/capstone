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
    df <- getData(file, random = T)
    item <- paste("training", i, sep="_")
    training.dfs[[item]] <- df
  }
  return(training.dfs)
} 

trainingDatasets <- createTrainingData(files[2])
testDataset <- getData(files[2], random = T)


#### N-GRAM MODEL FOR WORD PREDICTION

train_model <- function(df) {
  dtm <- CreateDtm(df$text,
                   doc_names = df$doc_id,
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
        arrange(desc(trans_prob), .by_group = TRUE) %>%
        ungroup() %>%
        select(c("w1_w2", "trans_prob"))

  return(w1_w2_prob)
}

training_probs_names <- character()
training_probs_names[[1]] <- "bigram" 


for (i in 1:length(trainingDatasets)) {
  var <- paste0("training_", i)
  training_probs_names[[i+1]] <- var 
  model <- train_model(trainingDatasets[[i]])
  assign(var, model) 
  # join tables for calculating averages
  if (i == 1) {
    training_probs <- model

  } else {
    training_probs <- full_join(training_probs, model, by = c("w1_w2"))
  }
}
names(training_probs) <- training_probs_names

# replace NAs with zeros

training_probs[is.na(training_probs <- training_probs)] <- 0

# calculate averages of each bigram

final_model <- training_probs %>%
  mutate(mean=rowMeans(training_probs[,-1])) %>%
  separate(bigram, c("w1", "w2")) %>%
  select(c(1,2,12)) %>%
  # keep only top 3
  group_by(w1) %>%
  top_n(3, mean)

# create test of Markov model - create test n-grams

test_words <- train_model(testDataset) %>%
  separate(w1_w2, c("w1", "w2")) %>%
  # keep only top 3
  group_by(w1) %>%
  top_n(3, trans_prob)

test_unigrams <- test_words %>%
  select(w1)

test_unigrams <- ungroup(unique(test_unigrams))  

test_unigrams <- test_unigrams$w1

test_model <- function(unigram, model) {
  for (i in 1:10) {
    w <- unigram[[i]]
    if (w %in% model$w1) {
      next_w <- model %>%
        filter(w == w1)
      next_w <- ungroup(next_w) %>%
        select(w2, mean)
      print(next_w)
    }
    else {
      print("Word not found.")
    }
  }
}

test_model(test_unigrams, final_model)

# Also look into: https://cran.r-project.org/web/packages/markovchain/markovchain.pdf

# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.