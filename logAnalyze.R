# logAnalyze.R

library(rjson)
library(ggplot2)
library(dplyr)
library(lubridate)

options(stringsAsFactors = FALSE)

# Load the post tags file
tags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(tags)

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'date', 'hits')
hitCounts$date <- as.Date(hitCounts$date)

livePostHit <- hitCounts[hitCounts$path %in% livePosts,]
summarizedPostHit<- livePostHit %>%
  group_by(path, month=floor_date(date, "month")) %>%
  summarize(hits=sum(hits))


ggplot(summarizedPostHit, aes(x = path, y = month, fill = hits)) +
  geom_tile() +
  coord_flip() +
  ggtitle("Post Hits Over Time") +
  scale_fill_continuous(low='white', high='red')

