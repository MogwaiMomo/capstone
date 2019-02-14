# Global options
options(stringsAsFactors = FALSE)
setwd(dirname(parent.frame(2)$ofile))

# load libraries
library(tm)
library(RCurl)
library(tidyverse)
library(tidytext)
#install dev version of ggplot2 to get stat_qq_line function
devtools::install_github("tidyverse/ggplot2")
library(ggplot2)
library(gridExtra)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(ggpubr)
library(textstem)
library(scales)
library(wordnet)
library(RDRPOSTagger)
library(LaF)


options <- list("0", "1", "2", "3","4", "5", "6","7","8", "9", "10")

program <- readline(prompt="What program would you like to run?")
program <- as.integer(program)

if (program == 0) {
 source('cleantexttidy.R', echo=TRUE)
} else if (program == 1) {
  source('week2q1.R', echo=TRUE)
} else if (program == 2) {
  source('week2q2.R', echo=TRUE)
} else if (program == 3) {
  source('week2q3.R', echo=TRUE)
} else if (program == 4) {
  source('week2q4.R', echo=TRUE)
} else if (program == 5) {
  source('week2q5.R', echo=TRUE)
} else if (program == 6) {
  source('week2q6.R', echo=TRUE)
} else if (program == 7) {
  source('week2q7.R', echo=TRUE)
} else if (program == 8) {
  source('week2q8.R', echo=TRUE)
} else if (program == 9) {
  source('week2q9.R', echo=TRUE)
} else if (program == 10) {
  source('ngramnodel.R', echo=TRUE)
} else {
  print("sorry, no match")
}



