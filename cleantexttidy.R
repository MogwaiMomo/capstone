# get data from URL into list of files
  # url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
  # destfile <- "./input/capstone-data.zip"
# 
  # download.file(url, destfile)
  # unzip(destfile, exdir ="./input/")
# #remove zip file
  # file.remove(destfile)
# create paths to each data file
file_dir <- paste(getwd(),"input/final/en_US", sep="/")
files <- list.files(file_dir, full.names = TRUE)

# convert files to csv
for (i in 1:length(files)) {
  csv = read.table(file=files[i], sep = "\t")
  write.csv(csv,file=paste0(sub(".txt","",files[i]),".csv"))
}


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
  # uncomment line 35 if you want only a small sample of lines
  n <- n*0.01
  # open file connection
  con <- file(file, open="r")
  # read in all lines
  lines <- as.data.frame(readLines(con, n, warn = FALSE))
  names(lines) <- c("text")
  #close connection
  close(con)
  lines$line = seq(1, nrow(lines), 1)
  lines <- lines %>% select(line, text)
  return(lines)
}


# create line dfs with word counts
raw.blog.df <- getData(files[1])
raw.news.df <- getData(files[2])
raw.twitter.df <- getData(files[3])

# lemmatize documents
lemma.blog.df <- data_frame(
  line = raw.blog.df$line,
  text = lemmatize_strings(raw.blog.df$text)
)

lemma.news.df <- data_frame(
  line = raw.news.df$line,
  text = lemmatize_strings(raw.news.df$text)
)

lemma.twitter.df <- data_frame(
  line = raw.twitter.df$line,
  text = lemmatize_strings(raw.twitter.df$text)
)


# create profanity-inclusive english stopword list
prof_url <- "https://raw.githubusercontent.com/xavier/expletive/master/data/english.txt"
prof_file <- getURL(prof_url, ssl.verifyhost=FALSE, ssl.verifypeer=FALSE)
prof_stopwords <- unlist(strsplit(prof_file, "\n"))
custom_stopwords <- data_frame(
  word = c(stopwords("english"), prof_stopwords),
  lexicon = "custom"
)
data(stop_words)
custom_stopwords <- rbind(stop_words, custom_stopwords)


# create tidy tokenized df (filter out numbers & stopwords)
tidy.blog <- lemma.blog.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word)) %>%
  filter(!(word %in% custom_stopwords$word))

tidy.news <- lemma.news.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word)) %>%
  filter(!(word %in% custom_stopwords$word))

tidy.twitter <- lemma.twitter.df %>%
  unnest_tokens(word, text) %>%
  filter(!grepl("[0-9]+", word)) %>%
  filter(!(word %in% custom_stopwords$word))

# create clean doc dfs (i.e recombine stopword-free tokens back into docs for further analysis)

# wrap paste function so it doesn't trigger an error from summarize
reduce_paste <- function(v) {
  Reduce(f=paste, x = v)
}

clean.blog.df <- tidy.blog %>%
  group_by(line) %>%
  summarise(text = reduce_paste(word))

clean.news.df <- tidy.news %>%
  group_by(line) %>%
  summarise(text = reduce_paste(word))

clean.twitter.df <- tidy.twitter %>%
  group_by(line) %>%
  summarise(text = reduce_paste(word))
