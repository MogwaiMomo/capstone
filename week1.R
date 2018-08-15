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

#### METHOD 1: GET SAMPLE OF TEXT FILE #####

getSample <- function(file) {
 
  # get the number of lines in file
  com <- paste0("wc -l ", file, " | awk '{ print $1 }'")
  n <- as.numeric(system(command=com, intern=TRUE))
  
  # open file connection
  con <- file(file, open="r")
  
  # create df for storing lines from file
  sample.df <- data.frame(
    doc_id = character(),
    text = character(),
    line = numeric()
    
  )
  
  # loop over a file connection
  for (i in 1:n) {
    # coinflip
    flip <- rbinom(1, 1, 0.01)
    # if true
    if (flip == 1) {
      print(paste("Processing line ", i, " of ", n, "..."))
      line <- readLines(con, 1, warn = FALSE)
      row <- data.frame(
        doc_id = NA,
        text = line,
        line = i
      )
      sample.df  <- rbind(sample.df, row)
    }
  }
  
  ids <- seq(1, nrow(sample.df), 1)
  sample.df$doc_id <- ids
  
  #close connection
  close(con)
  return(sample.df) 
}

# get data
blog.sample <- getSample(files[[1]])
# get time
blog.time <- system.time(getSample(files[[1]]))

# get data
news.sample <- getSample(files[[2]])
# get time
news.time <- system.time(getSample(files[[2]]))

# get data
twitter.sample <- getSample(files[[3]])
# get time
twitter.time <- system.time(getSample(files[[3]]))



#### METHOD 2: GET FULL DATA #####
getFullData <- function(x) {
  
  # get the number of lines in file
  com <- paste0("wc -l ", file, " | awk '{ print $1 }'")
  n <- as.numeric(system(command=com, intern=TRUE))
  
  # open file connection
  con <- file(file, open="r")
  
  # create df for storing lines from file
  full.df <- data.frame(
    doc_id = character(),
    text = character(),
    line = numeric()
  )
  
  # loop over a file connection
  for (i in 1:n) {
      line <- readLines(con, 1, warn = FALSE)
      row <- data.frame(
        doc_id = NA,
        text = line,
        line = i
      )
      full.df  <- rbind(full.df, row)
  }
  
  ids <- seq(1, nrow(sample.df), 1)
  sample.df$doc_id <- ids
  
  #close connection
  close(con)
  return(full.df) 
}

#### END: GET FULL DATA #####


# Write sample lists to corpora

blog <- Corpus(DataframeSource(blog.sample))
news <- Corpus(DataframeSource(news.sample))
twitter <- Corpus(DataframeSource(twitter.sample))

# Create a profanity filter using the english and international files here: 

# get profanity lists
# url
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

# clean each sample corpus
cl_blog <- cleanString(blog)
cl_twitter <- cleanString(twitter)
cl_news <- cleanString(news)

# create TDM
blog_dtm <- DocumentTermMatrix(cl_blog)
twitter_dtm <- DocumentTermMatrix(cl_twitter)
news_dtm <- DocumentTermMatrix(cl_news)


## QUIZ 1 ##
# 
# #Q1: The 𝚎𝚗_𝚄𝚂.𝚋𝚕𝚘𝚐𝚜.𝚝𝚡𝚝  file is how many megabytes?
# 
# ans1 <- file.info(files[[1]])$size
# 
# #Q2: The 𝚎𝚗_𝚄𝚂.𝚝𝚠𝚒𝚝𝚝𝚎𝚛.𝚝𝚡𝚝 has how many lines of text?
# 
# ans2 <- dim(twitter.data)[[1]]
# 
# #Q3: What is the length of the longest line seen in any of the three en_US data sets?
# 
# # combine all corpora
# full.data <- rbind(twitter.data, blog.data)
# full.data <- rbind(full.data, news.data)
# 
# # convert to character vector
# full.data$line <- as.character(full.data$line)
# 
# # get length of each line
# with_line_lengths <- full.data %>% 
#   mutate(length=nchar(line)) %>%
#   arrange(desc(length))
# 
# # get max length
# max_length <- with_line_lengths[1,]
# ans3 <- max_length$length[1]
# 
# #Q4: In the en_US twitter data set, if you divide the number of lines where the word "love" (all lowercase) occurs by the number of lines the word "hate" (all lowercase) occurs, about what do you get?
# 
# match1 <- "[ .,;:!?]*love[ .,;:!?]*"
# match2 <- "[ .,;:!?]*hate[ .,;:!?]*"
# 
# love_df <- twitter.data %>%
#   filter(grepl(match1, line))
# 
# hate_df <- twitter.data %>%
#   filter(grepl(match2, line))
# 
# ans4 = nrow(love_df)/nrow(hate_df)
# 
# 
# #Q5: The one tweet in the en_US twitter data set that matches the word "biostats" says what?
# 
# match3 <- "biostats"
# 
# ans5 <-  twitter.data %>%
#   filter(grepl(match3, line)) %>%
#   select(line)
# 
# #Q6: How many tweets have the exact characters "A computer once beat me at chess, but it was no match for me at kickboxing". (I.e. the line matches those characters exactly.)
# 
# match4 <- "^A computer once beat me at chess, but it was no match for me at kickboxing$"
# 
# ans6 <-  twitter.data %>%
#   filter(grepl(match4, line)) %>%
#   select(line)
# 
