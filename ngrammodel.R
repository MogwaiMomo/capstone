# General methodology: Treat every token as a state and predict the next word based on the previous state.

# Stages of making the model:

# Tokenize the data

# Training data: 

training_data <- blog.docs %>%
  select(doc_id = line, text)


# load textmineR package
library(textmineR)

# helpful references:
# https://datawarrior.wordpress.com/2018/01/22/document-term-matrix-text-mining-in-r-and-python/
# https://cran.r-project.org/web/packages/textmineR/vignettes/a_start_here.html

# create dtm
dtm <- CreateDtm(training_data$text,
                doc_names = training_data$doc_id,
                ngram_window = c(1, 3),
                lower = TRUE,
                remove_punctuation = TRUE,
                remove_numbers = TRUE
                #stem_lemma_function = wordStem
)

# Exploratory Analysis

doc_term <- dim(dtm)

# number of docs
docs <- nrow(dtm)
terms <- ncol(dtm)

# 1-gram freq table


# 2-gram freq table


# create TDM

# explore TDM



# Build the state pairs

# initial word 

# first word (no prev2 word) 

# second-order probabilities

# 'END' pair for end of sentences

# Do simple counts and calculate probabilities 
# (i.e. create a transition matrix)


# Will use 10-fold cross validation for test-error estimation. Train the data on the blog text. (Look into Caret package and 'cv' options for this.)


# Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.