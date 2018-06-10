#!/usr/bin/env Rscript
# make_plots.R
# Henry J Schmale
# Log Analysis Plotting Script

library(rjson)
library(ggplot2)
library(dplyr)
library(lubridate)
library(reshape2)

options(stringsAsFactors = FALSE)

if (! interactive()) {
  options(device = 'pdf')
  pdf(width = 11, height = 8.5)
}

# Load the post tags file
tags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(tags)

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'date', 'hits')
hitCounts$date <- as.Date(hitCounts$date)
livePostHit <- hitCounts[hitCounts$path %in% livePosts,]
livePostHit$month <- floor_date(livePostHit$date, 'month')

#################################################
# Total Number Of Hits
#################################################
totalHits <- livePostHit %>%
  group_by(path) %>%
  summarise(hits=sum(hits))

ggplot(totalHits, aes(x = path, y = hits)) +
  geom_bar(stat = 'identity') +
  theme(axis.text = element_text(angle=75, hjust = 1)) +
  ggtitle("Total Views of Posts") +
  scale_y_log10()

#################################################
# Monthly Hits
#################################################

hits_per_month <- livePostHit %>%
  group_by(month = floor_date(date, 'month')) %>%
  summarise(hits = sum(hits))

ggplot(hits_per_month, aes(x = month, y = hits)) +
  geom_bar(stat = 'identity') +
  ggtitle("Post Hits Per Month") +
  scale_y_log10()

#################################################
# Grouped By Month
#################################################
summarizedPostHit <- livePostHit %>%
  group_by(path, dates=floor_date(date, "month")) %>%
  summarize(hits=sum(hits))

ggplot(summarizedPostHit, aes(x = path, y = dates, fill = hits)) +
  geom_tile() +
  coord_flip() +
  geom_text(aes(label = hits)) +
  ggtitle("Post Hits Over Time Grouped By Month") +
  scale_fill_continuous(low='blue', high='red')


#################################################
# Grouped By WeekDay
#################################################

weekdayPostHit <- livePostHit %>%
  group_by(path, weekday = wday(date)) %>%
  summarize(hits=sum(hits))

ggplot(weekdayPostHit, aes(x = path, y = weekday, fill = hits)) +
  geom_tile() +
  coord_flip() +
  geom_text(aes(label = hits)) +
  ggtitle("Post Hits Grouped By Day Of Week - My Blog") +
  scale_fill_continuous(low='blue', high='red')

#################################################
# Grouped By Day of Month
#################################################

monthdayPostHit <- livePostHit %>%
  group_by(path, monthday = mday(date)) %>%
  summarize(hits=sum(hits))

ggplot(monthdayPostHit, aes(x = path, y = monthday, fill = hits)) +
  geom_tile() +
  coord_flip() +
  geom_text(aes(label = hits)) +
  ggtitle("Post Hits Grouped By Day Of Month - My Blog") +
  scale_fill_continuous(low='blue', high='red')


