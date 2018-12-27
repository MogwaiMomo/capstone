# METHOD 1: Using Google's CLD3 package (language detection)

library(cld3)

# Create a test df with 3 different languages

# Get data from other langs 
file_dir_de <- paste(getwd(),"input/final/de_DE", sep="/")
file_dir_fi <- paste(getwd(),"input/final/fi_FI", sep="/")
file_dir_ru <- paste(getwd(),"input/final/ru_RU", sep="/")


files_de <- list.files(file_dir_de, full.names = TRUE)
files_fi <- list.files(file_dir_fi, full.names = TRUE)
files_ru <- list.files(file_dir_ru, full.names = TRUE)


# read in text from files
raw.de.blog.df <- getData(files_de[1])
raw.fi.blog.df <- getData(files_fi[1])
raw.ru.blog.df <- getData(files_ru[1])

# create test df using random selection
create_multilang_df <- function(y) {
  df <- data.frame(
    line = NULL,
    text = NULL
  )
  for (n in 1:y) {
    print(n)
    # draw a random number between 0 and 1
    i <- runif(1, min = 0, max = 1)
    # if i is between 0 and 0.25, english
    if (i < 0.25) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.blog.df)))
      df <- rbind(df, raw.blog.df[row,])
    }
    # if i is between 0.25 and 0.5, german
    else if (i >= 0.25 && i < 0.5) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.de.blog.df)))
      df <- rbind(df, raw.de.blog.df[row,])
    }
    # if i is between 0.5 and 0.75, finnish
    else if (i >= 0.5 && i < 0.75) {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.fi.blog.df)))
      df <- rbind(df, raw.fi.blog.df[row,])
    }
    # if i is between 0.75 and 1, russian
    else {
      row <- as.integer(runif(1, min = 0, max = nrow(raw.ru.blog.df)))
      df <- rbind(df, raw.ru.blog.df[row,])
    }
  }
  return(df)
}


test.df <- create_multilang_df(100)

# try it using lapply
test.df$lang <- lapply(test.df$text, detect_language)

