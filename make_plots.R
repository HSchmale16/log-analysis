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

#################################################
# Total Number Of Hits
#################################################
totalHits <- livePostHit %>%
  group_by(path) %>%
  summarise(hits=sum(hits))

ggplot(totalHits, aes(x = path, y = hits, label = hits)) +
  geom_bar(stat = 'identity') +
  geom_text(size = 3, vjust = -1) +
  theme(axis.text = element_text(angle=75, hjust = 1)) +
  ggtitle("Total Views of Posts")

#################################################
# Post Hits in the Last N Days (LAST_N_DAYS)
#################################################
LAST_N_DAYS <- 30
bisect_date <- as.Date(today(), format="%Y-%m-%d") - LAST_N_DAYS

livePostHit %>%
  filter(date >= bisect_date) %>%
  group_by(path) %>%
  summarise(hits = sum(hits)) %>%
  ggplot(aes(x = path, y = hits, label = hits)) +
    geom_bar(stat='identity') +
    geom_text(size = 3, vjust = -1) +
    theme(axis.text = element_text(angle=75, hjust = 1)) +
    ggtitle(paste("Post Hits in the Past", LAST_N_DAYS, "Days as of ", today()))


livePostHit %>%
    filter(date >= bisect_date) %>%
    group_by(path, date) %>%
    summarize(hits = sum(hits)) %>%
    ggplot(aes(x = path, y = date, fill = hits)) +
      geom_tile() +
      coord_flip() +
      geom_text(aes(label = hits)) +
      ggtitle("When posts were hit in the last 30 days") +
      scale_fill_continuous(low='blue', high='red')

#################################################
# Daily Hits
#################################################
daily_hits <- livePostHit %>%
    group_by(date) %>%
    summarise(daily=sum(hits)) %>%
    arrange(date) %>% 
    mutate(total=cumsum(daily), year=year(date), yearday=strftime(date, "%j"))

daily_hits$yearday <- as.numeric(daily_hits$yearday)
daily_hits$year <- as.factor(daily_hits$year)

ggplot(daily_hits, aes(x = yearday, y = daily, fill=year)) +
    geom_bar(stat='identity') + 
    facet_grid(year ~ .) +
    ggtitle("Daily Post Hit Counts")

daily_hits %>%
    group_by(year) %>% 
    arrange(date) %>% 
    mutate(cs = cumsum(daily)) %>%
    ggplot(aes(x = yearday, y = cs, color=year)) +
        geom_line() +
        ggtitle('Cummulative Daily Post Hits Year Over Year')

#################################################
# Monthly Hits
#################################################

hits_per_month <- livePostHit %>%
  group_by(month = floor_date(date, 'month')) %>%
  summarise(hits = sum(hits))

ggplot(hits_per_month, aes(x = month, y = hits, label = hits)) +
  geom_bar(stat = 'identity') +
  geom_text(size = 3, vjust = -1) +
  ggtitle("Post Hits Per Month") 

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
  group_by(path, weekday = wday(date, label = TRUE)) %>%
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


