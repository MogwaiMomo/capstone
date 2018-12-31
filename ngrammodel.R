# General methodology: Treat every token as a state and predict the next word based on the previous state.

# Stages of making the model:

# Tokenize the data

# Training data: 

training_data <- blog.docs %>%
  select(doc_id = line, text)

# write sample lists to corpora
createCorpus <- function(text.df) {
  # create doc_id column
  corpus <- Corpus(DataframeSource(text.df))
  return(corpus)
}

# Write function that cleans and tokenizes lines of text
cleanString <- function(corpus) {
  # get profanity lists
  prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"
  # get text from urls
  prof_file <- getURL(prof_url, ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)
  # create profane stopword character list
  prof_stopwords <- unlist(strsplit(prof_file, "\n"))
  
  # Create full stopwords list, including profanity terms
  custom_stopwords <- c(stopwords("english"), prof_stopwords)
  # lowercase
  corpus <- tm_map(corpus, content_transformer(tolower))
  #create toSpace content transformer to deal with hyphen/colon issues
  toSpace <- content_transformer(function(x, pattern) {return (gsub(pattern, " ", x))})
  # corpus <- tm_map(corpus, toSpace, "-")
  # corpus <- tm_map(corpus, toSpace, ":")
  # corpus <- tm_map(corpus, toSpace, "’")
  # corpus <- tm_map(corpus, toSpace, "‘")
  # corpus <- tm_map(corpus, toSpace, "“")
  # corpus <- tm_map(corpus, toSpace, "”")
  # corpus <- tm_map(corpus, toSpace, "—")
  # corpus <- tm_map(corpus, toSpace, " -")
  # remove punctuation
  corpus <- tm_map(corpus, FUN = removePunctuation)
  # remove numbers
  corpus <- tm_map(corpus, FUN = removeNumbers)
  # strip whitespace
  corpus <- tm_map(corpus, FUN = stripWhitespace)
  # remove stopwords
  #corpus <- tm_map(corpus, removeWords, custom_stopwords)
  return(corpus)
  # stem document
  #corpus <- tm_map(corpus, stemDocument)
}

# create corpus
training_corp <- createCorpus(training_data)

# clean each sample corpus
system.time(clean_corp <- cleanString(training_corp))

# create TDM
dtm <- DocumentTermMatrix(clean_corp)

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