# TO DO LIST - WEEK 2

# 2018-12-12:

NEXT: pre-process documents using best practices before gathering bigrams & trigrams: 
https://www.analyticsvidhya.com/blog/2015/10/6-practices-enhance-performance-text-classification-model/

Then get back to: 
https://www.tidytextmining.com/ngrams.html


# Lesson: when doing exploratory analysis, visualize first, then run statistical test.


## Tasks to accomplish

### PART 1: Exploratory analysis

1. Perform a thorough exploratory analysis of the data, understanding the distribution of words and relationship between the words in the corpora.
2. Understand frequencies of words and word pairs - build figures and tables to understand variation in the frequencies of words and word pairs in the data.

#### Questions to consider

1. DONE - Some words are more frequent than others - what are the distributions of word frequencies?

2. What are the frequencies of 2-grams and 3-grams in the dataset?

- Make sure to do the full data (not just a sample) once the code has been written before moving on to next question

3. How many unique words do you need in a frequency sorted dictionary to cover 50% of all word instances in the language? 90%?

(What is this actually asking??)
Possible answer: 
https://www.analyticsvidhya.com/blog/2014/09/creating-dictionary-text-mining/

Other references:
https://en.wikipedia.org/wiki/Predictive_text#Dictionary_vs._non-dictionary_systems
https://medium.com/parrot-prediction/the-tao-of-text-normalization-2e7aecd1861



4. How do you evaluate how many of the words come from foreign languages?

5. Can you think of a way to increase the coverage -- identifying words that may not be in the corpora or using a smaller number of words in the dictionary to cover the same number of phrases?


### PART 2: Modeling

1. Build basic n-gram model - using the exploratory analysis you performed, build a basic n-gram model for predicting the next word based on the previous 1, 2, or 3 words.

2. Build a model to handle unseen n-grams - in some cases people will want to type a combination of words that does not appear in the corpora. Build a model to handle cases where a particular n-gram isn't observed.

#### Questions to consider

1. How can you efficiently store an n-gram model (think Markov Chains)?
2. How can you use the knowledge about word frequencies to make your model smaller and more efficient?
3. How many parameters do you need (i.e. how big is n in your n-gram model)?
4. Can you think of simple ways to "smooth" the probabilities (think about giving all n-grams a non-zero probability even if they aren't observed in the data) ?
5. How do you evaluate whether your model is any good?
6. How can you use backoff models to estimate the probability of unobserved n-grams?

---

Hints, tips, and tricks

As you develop your prediction model, two key aspects that you will have to keep in mind are the size and runtime of the algorithm. These are defined as:

Size: the amount of memory (physical RAM) required to run the model in R
Runtime: The amount of time the algorithm takes to make a prediction given the acceptable input
Your goal for this prediction model is to minimize both the size and runtime of the model in order to provide a reasonable experience to the user.

Keep in mind that currently available predictive text models can run on mobile phones, which typically have limited memory and processing power compared to desktop computers. Therefore, you should consider very carefully (1) how much memory is being used by the objects in your workspace; and (2) how much time it is taking to run your model. Ultimately, your model will need to run in a Shiny app that runs on the shinyapps.io server.

Tips, tricks, and hints

Here are a few tools that may be of use to you as you work on their algorithm:

object.size(): this function reports the number of bytes that an R object occupies in memory
Rprof(): this function runs the profiler in R that can be used to determine where bottlenecks in your function may exist. The profr package (available on CRAN) provides some additional tools for visualizing and summarizing profiling data.
gc(): this function runs the garbage collector to retrieve unused RAM for R. In the process it tells you how much memory is currently being used by R.
There will likely be a tradeoff that you have to make in between size and runtime. For example, an algorithm that requires a lot of memory, may run faster, while a slower algorithm may require less memory. You will have to find the right balance between the two in order to provide a good experience to the user.
