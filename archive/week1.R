# Global options
options(stringsAsFactors = FALSE)
setwd(dirname(parent.frame(2)$ofile))

# load libraries
library(tm)
library(dplyr)
library(RCurl)

# download dataset from URL
url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
destfile <- "./input/capstone-data.zip"

download.file(url, destfile)
unzip(destfile, exdir ="./input/")
#remove zip file
file.remove(destfile)
# create paths to each data file
file_dir <- paste(getwd(),"input/final/en_US", sep="/")
files <- list.files(file_dir, full.names = TRUE)

# get the number of lines in file
getTotalLines <- function(file) {
  com <- paste0("wc -l ", file, " | awk '{ print $1 }'")
  n <- as.numeric(system(command=com, intern=TRUE))
  return(n)    
}

# read in text from files
getData <- function(file) {
  # get the number of lines in file
  n <- getTotalLines(file)
  # open file connection
  con <- file(file, open="r")
  # read in all lines
  lines <- as.data.frame(readLines(con, n, warn = FALSE))
  names(lines) <- c("text")
  #close connection
  close(con)
  return(lines)
}


# Write sample lists to corpora
createCorpus <- function(text.df) {
  # create doc_id column
  text.df$doc_id <- seq(1, nrow(text.df), 1)
  corpus <- Corpus(DataframeSource(text.df))
  return(corpus)
}



## QUIZ 1 ##
# 
# #Q1: The 𝚎𝚗_𝚄𝚂.𝚋𝚕𝚘𝚐𝚜.𝚝𝚡𝚝  file is how many megabytes?

q1 <- file.size(files[[1]])/1000000
 
# #Q2: The 𝚎𝚗_𝚄𝚂.𝚝𝚠𝚒𝚝𝚝𝚎𝚛.𝚝𝚡𝚝 has how many lines of text?

q2 <- getTotalLines(files[[2]])
 
# #Q3: What is the length of the longest line seen in any of the three en_US data sets?

# get full data
system.time(blog <- getData(files[[1]]))
system.time(news <- getData(files[[2]]))
system.time(twitter <- getData(files[[3]]))


getMaxLineLength <- function(dataframe) {
  # get length of each string
  dataframe <- dataframe %>% 
    mutate(length = nchar(text)) %>%
  # identify max of length column
    summarise(max = max(length))
  return(dataframe)
}

max_list <- list(
  "blog" = as.numeric(getMaxLineLength(blog)),
  "news" = as.numeric(getMaxLineLength(news)),
  "twitter" = as.numeric(getMaxLineLength(twitter))
)

q3 <- max(unlist(max_list))


#Q4: In the en_US twitter data set, if you divide the number of lines where the word "love" (all lowercase) occurs by the number of lines the word "hate" (all lowercase) occurs, about what do you get?

match1 <- "[ .,;:!?]*love[ .,;:!?]*"
match2 <- "[ .,;:!?]*hate[ .,;:!?]*"

love_df <- twitter %>%
  filter(grepl(match1, text))

hate_df <- twitter %>%
  filter(grepl(match2, text))

q4 = nrow(love_df)/nrow(hate_df)


# #Q5: The one tweet in the en_US twitter data set that matches the word "biostats" says what?

match3 <- "biostats"
q5 <-  as.character(twitter %>%
  filter(grepl(match3, text)) %>%
  select(text))

# #Q6: How many tweets have the exact characters "A computer once beat me at chess, but it was no match for me at kickboxing". (I.e. the line matches those characters exactly.)

match4 <- "^A computer once beat me at chess, but it was no match for me at kickboxing$"

q6 <- as.numeric(twitter %>%
  filter(grepl(match4, text)) %>%
  select(text) %>%
  summarise(count = n()))



# Create a profanity filter using the english and international files here:

# get profanity lists
prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"

# get text from urls
prof_file <- getURL("https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt", ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)
prof_stopwords <- unlist(strsplit(prof_file, "\n"))

# Create full stopwords list, including profanity terms
custom_stopwords <- c(stopwords("english"), prof_stopwords)

# Write function that cleans and tokenizes lines of text
cleanString <- function(corpus) {
# lowercase
  corpus <- tm_map(corpus, content_transformer(tolower))
# remove punctuation
  corpus <- tm_map(corpus, FUN = removePunctuation)
# remove numbers
  corpus <- tm_map(corpus, FUN = removeNumbers)
# remove stopwords
  corpus <- tm_map(corpus, removeWords, custom_stopwords)
# strip whitespace
  corpus <- tm_map(corpus, FUN = stripWhitespace)
  return(corpus)
}

# Create corpuses
blog <- createCorpus(blog)
twitter <- createCorpus(twitter)
news <- createCorpus(news)

# clean each sample corpus
blog <- cleanString(blog)
twitter <- cleanString(twitter)
news <- cleanString(news)

# create TDM
blog_dtm <- DocumentTermMatrix(blog)
twitter_dtm <- DocumentTermMatrix(twitter)
news_dtm <- DocumentTermMatrix(news)
