# General methodology: Treat every token as a state and predict the next word based on the previous state.

# Stages of making the model:

# Tokenize the data

# Training data: 

training_data <- blog.docs %>% # NOT lemmatized
  select(doc_id = line, text)


# load textmineR package
library(textmineR)

# helpful references:
# https://datawarrior.wordpress.com/2018/01/22/document-term-matrix-text-mining-in-r-and-python/
# https://cran.r-project.org/web/packages/textmineR/vignettes/a_start_here.html

# create dtm
dtm <- CreateDtm(training_data$text,
                doc_names = training_data$doc_id,
                ngram_window = c(1, 2),
                lower = TRUE,
                remove_punctuation = TRUE,
                remove_numbers = TRUE,
                stopword_vec = NULL # don't remove stopwords!
                #stem_lemma_function = wordStem
)

# Exploratory Analysis

doc_term <- dim(dtm)

# number of docs
docs <- nrow(dtm)
# number of terms
terms <- ncol(dtm)



# get term frequency for the dtm
tf_matrix <- TermDocFreq(dtm = dtm)
tf_matrix <- tf_matrix[order(tf_matrix$term_freq, decreasing = TRUE), ]

# general term freq table

tf_terms <- tf_matrix %>%
  filter(!grepl("_", term)) %>%
  
  # prob of initial word
  mutate(p_initial = term_freq / sum(term_freq))

  # calculate prob of 2nd word as function of initial word

  # p_second <- function (initial_word) {

      # create df that filters for all bigrams that start with the initial word

      # calculate p_bigram for that df

      # choose the top 3 entries

  # } 

# bigram freq table
tf_bigrams <- tf_matrix %>%
  filter(grepl("_", term)) %>%
  filter(!grepl("_.+_", term))

# trigram freq table
tf_trigrams <- tf_matrix %>%
  filter(grepl("_.+_", term))

# Build the state pairs 





# first word (no prev2 word) 

# second-order probabilities

# 'END' pair for end of sentences

# Do simple counts and calculate probabilities 
# (i.e. create a transition matrix)


# Will use 10-fold cross validation for test-error estimation. Train the data on the blog text. (Look into Caret package and 'cv' options for this.)


# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.