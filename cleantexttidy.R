# get data from URL into list of files
url <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

destfile <- "./input/capstone-data.zip"

download.file(url, destfile)
unzip(destfile, exdir ="./input/")
#remove zip file
file.remove(destfile)
# create paths to each data file
file_dir <- paste(getwd(),"input/final/en_US", sep="/")
files <- list.files(file_dir, full.names = TRUE)
# delete all csvs, if they exist
for (i in 1:length(files)) {
  if (grepl(".csv", files[[i]])) {
    file.remove(files[[i]])
  }
}

files <- list.files(file_dir, full.names = TRUE)

# convert files to csv
for (i in 1:length(files)) {
  csv = read.table(file=files[i], sep = "\t", quote="", fill=FALSE, skipNul = TRUE)
  write.csv(csv,file=paste0(sub(".txt","",files[i]),".csv"), row.names = FALSE, quote = FALSE)
}

files <- list.files(file_dir, full.names = TRUE)

# get the number of lines in file
getTotalLines <- function(file) {
  com <- paste0("wc -l ", file, " | awk '{ print $1 }'")
  n <- as.numeric(system(command=com, intern=TRUE))
  return(n)    
}

##### NON RANDOM DATA ######

# read in text from files
getData <- function(file, random = F) {
  
  nlines <- getTotalLines(file)
  # uncomment line 35 if you want only a small sample of lines
  n <- as.integer(nlines*0.01111)
  
  if (random) {
    # read in all lines
    lines <- as.data.frame(sample_lines(file, n, nlines = nlines))
    names(lines) <- c("text")
  } else {
    # open file connection
    con <- file(file, open="r")
    # read in all lines
    lines <- as.data.frame(readLines(con, n, warn = FALSE))
    names(lines) <- c("text")
    #close connection
    close(con)
  }
    lines$doc_id = seq(1, nrow(lines), 1)
    lines <- lines %>% select(doc_id, text)
    return(lines)
}

##### READLINES VERSION #########

# raw.blog.df <- getData(files[2], random = F)
# raw.news.df <- getData(files[4], random = F)
# raw.twitter.df <- getData(files[6], random = F)

#################################

##### SAMPLELINES VERSION #######

raw.blog.df <- getData(files[1], random = T)
raw.news.df <- getData(files[3], random = T)
raw.twitter.df <- getData(files[5], random = T)

raw.dfs <- list(
  blog = raw.blog.df,
  news = raw.news.df,
  twitter = raw.twitter.df
)

#################################



# lemmatize documents
lemma.blog.df <- data_frame(
  doc_id = raw.blog.df$doc_id,
  text = lemmatize_strings(raw.blog.df$text)
)

lemma.news.df <- data_frame(
  doc_id = raw.news.df$doc_id,
  text = lemmatize_strings(raw.news.df$text)
)

lemma.twitter.df <- data_frame(
  doc_id = raw.twitter.df$doc_id,
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
  group_by(doc_id) %>%
  summarise(text = reduce_paste(word))

clean.news.df <- tidy.news %>%
  group_by(doc_id) %>%
  summarise(text = reduce_paste(word))

clean.twitter.df <- tidy.twitter %>%
  group_by(doc_id) %>%
  summarise(text = reduce_paste(word))

clean.dfs <- list(
  blog = clean.blog.df,
  news = clean.news.df,
  twitter = clean.twitter.df
)


# write data to file 


# raw texts from source
for (i in 1:length(raw.dfs)) {
  fwrite(raw.dfs[[i]],file=paste0("raw_", names(raw.dfs[i]),".csv"), quote = "auto")
}

# cleaned and lemmatized texts
for (i in 1:length(clean.dfs)) {
  fwrite(clean.dfs[[i]],file=paste0("clean_", names(clean.dfs[i]),".csv"), quote = "auto")
}

# remove objects after saving

rm(list = ls())

