common_blog_news <- inner_join(blog.freq, news.freq, by = "word")
common_news_twitter <- inner_join(news.freq, twitter.freq, by = "word")
common_twitter_blog <- inner_join(twitter.freq, blog.freq, by = "word")
common_full <- inner_join(common_blog_news, common_news_twitter, by = "word")

all.freq <- bind_rows(mutate(tidy.blog, source = "blog"),
                      mutate(tidy.news, source = "news"),
                      mutate(tidy.twitter, source = "twitter")) %>%
  count(source, word) %>%
  group_by(source) %>%
  mutate(proportion = n / sum(n)) %>%
  select(-n) %>%
  spread(source, proportion) %>% # spread groups across columns
  gather(source, proportion, "news":"twitter")

# Visualization of word frequency similarity between sources

p8 <- ggplot(all.freq, aes(x = proportion, y = blog, color = blog- proportion)) +
  geom_abline(color = "gray40", lty = 2) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  scale_color_gradient(limits = c(0, 0.001), low = "darkslategray4", high = "gray75") +
  facet_wrap(~source, ncol = 2) +
  theme(legend.position="none") +
  labs(y = "blog", x = NULL)


