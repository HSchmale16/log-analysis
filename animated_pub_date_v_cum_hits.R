# Animated Plot of PubDays vs Total Hits
# Henry J Schmale

library(rjson)
library(ggplot2)
library(dplyr)
library(lubridate)
library(reshape2)
library(scales)
library(gganimate)
library(tidyr)

# Load the post tags file
tags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(tags)

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'date', 'hits')
hitCounts$date <- as.Date(hitCounts$date)

# deadPostHit <- hitCounts[!hitCounts$path %in% livePosts,]

# Select only those posts which currently are live on my site.
livePostHit <- hitCounts[hitCounts$path %in% livePosts,]

normHitsSincePub <- livePostHit %>%
  group_by(path) %>%
  arrange(date) %>%
  mutate(
    hitsSincePub = cumsum(hits),
    pubDate = as.Date(substr(path, 2, 11)),
    daysSincePub = as.integer(date - pubDate)
  ) %>%
  complete(date = seq.Date(min(date), max(date), by="day")) %>%
  fill(hitsSincePub, pubDate) %>%
  mutate(daysSincePub = as.integer(date - pubDate))

p <- ggplot(normHitsSincePub, aes(x=daysSincePub, y=hitsSincePub)) +
  geom_point() +
  labs(title = "As of: {frame_time}") +
  transition_time(date)

animate(p, renderer = ffmpeg_renderer(), duration=15)

