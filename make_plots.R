#!/usr/bin/env Rscript
# make_plots.R
# Henry J Schmale
# Log Analysis Plotting Script

required.packages <- c(
    "rjson", "ggplot2", "dplyr", "lubridate", "reshape2", "scales", "tidyr"
)

new.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
    install.packages(new.packages,  repos='http://cran.us.r-project.org')
}

suppressPackageStartupMessages(suppressWarnings({
    library(rjson)
    library(ggplot2)
    library(dplyr)
    library(lubridate)
    library(reshape2)
    library(scales)
    library(tidyr)
}))

#############################################
# Some Knobs to twist and turn
#############################################

NUM_MOST_RECENT_POSTS <- 6

LAST_N_DAYS <- 30
bisect_date <- as.Date(today(), format="%Y-%m-%d") - LAST_N_DAYS
SEVEN_DAYS_AGO <- as.Date(today(), format="%Y-%m-%d") - 7

#############################################
# Begin primary code execution
#############################################
#options(stringsAsFactors = FALSE)

if (! interactive()) {
  options(device = 'pdf')
  pdf(width = 11, height = 8.5)
}

# Load the post tags file
tags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(tags)


# For the Future to develop a better category stuff
buildPostToTagMapping <- function(posttags_json=tags) {
  posts <- c()
  tag_vec <- c()
  for (postname in names(tags)) {
    for (tag in tags[[postname]]) {
      posts <- append(posts, postname)
      tag_vec <- append(tag_vec, tag)
    }
  }
  data.frame(
    path = posts,
    tag = tag_vec
  )
}

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'date', 'hits')
hitCounts$date <- as.Date(hitCounts$date)

# deadPostHit <- hitCounts[!hitCounts$path %in% livePosts,]

# Select only those posts which currently are live on my site.
livePostHit <- hitCounts[hitCounts$path %in% livePosts,]




#################################################
# Total Number Of Hits
#################################################
postTotalHitsAllTime <- livePostHit %>%
  group_by(path) %>%
  summarise(hits=sum(hits), .groups = 'drop')

ggplot(postTotalHitsAllTime, aes(y = path, x = hits, label = hits)) +
  geom_bar(stat = 'identity', fill="lightblue") +
  geom_text(size = 3) +
  ggtitle("Total Views of Posts")

# Gets the most viewed posts of all time
getMostViewedAllTimePosts <- function(n=NUM_MOST_RECENT_POSTS) {
  postTotalHitsAllTime %>% arrange(-hits) %>% top_n(n) %>% select(path)
}

#buildPostToTagMapping() %>%
#  ggplot(aes(y=tag)) +
#    geom_bar() +
#    ggtitle("Number of Posts Under Tags")


#################################################
# Post Hits in the Last N Days (LAST_N_DAYS)
#################################################


livePostHit %>%
  filter(date >= bisect_date) %>%
  group_by(path) %>%
  summarise(hits = sum(hits), .groups = 'drop') %>%
  filter(hits > 1) %>%
  ggplot(aes(y = path, x = hits, label = hits)) +
    geom_bar(stat="identity") +
    geom_text(size = 3, hjust = -1) +
    ggtitle(paste("Post Hits in the Past", LAST_N_DAYS, "Days as of ", today()))

livePostHit %>%
  filter(date >= SEVEN_DAYS_AGO) %>%
  group_by(path) %>%
  summarise(hits = sum(hits), .groups = 'drop') %>%
  filter(hits > 1) %>%
  ggplot(aes(y = path, x = hits, label=hits)) +
    geom_bar(stat="identity") +
    geom_text(size = 3, hjust = -1) +
    theme(legend.position="bottom") +
    ggtitle(paste("Post Hits in the Past", 7, "Days as of", today()))

overAllHistInLastNDays <- function(nDays) {
  from_date <- as.Date(today(), format="%Y-%m%-%d") - nDays
  hitsPerDay <- livePostHit %>%
    filter(date >= from_date) %>%
    group_by(date) %>%
    summarise(hits = sum(hits), .groups='drop')
    
  totalHits <- sum(hitsPerDay$hits)

  ggplot(hitsPerDay, aes(x = date, y = hits, label=hits)) +  
    geom_bar(stat='identity') +
    geom_text(size=3, vjust=-1) +
    theme(axis.text = element_text(angle=75, hjust = 1)) +
    ggtitle(paste("Hit Counts in the Past", LAST_N_DAYS, "Days as of ", today(), " (total = ", totalHits, ")"))
}

overAllHistInLastNDays(7)
overAllHistInLastNDays(30)
          

livePostHit %>%
    filter(date >= bisect_date) %>%
    group_by(path, date) %>%
    summarize(hits = sum(hits), .groups = 'drop') %>%
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
    summarise(daily=sum(hits), .groups = 'drop') %>%
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
# Grouped By Quarter, since it's getting really
# quite big my 
#################################################
summarizedPostHit <- livePostHit %>%
  group_by(path, dates=floor_date(date, "quarter")) %>%
  summarize(hits=sum(hits), pubDate=as.Date(substr(path,2,11)), .groups = 'drop')

ggplot(summarizedPostHit, aes(x = path, y = dates, fill = hits)) +
  geom_tile() +
  coord_flip() +
  geom_text(aes(label = hits)) +
  ggtitle("Post Hits Over Time Grouped By Quarter") +
  scale_fill_continuous(low='blue', high='red')


#################################################
# Grouped By Day of Week
# Ex. Sat, Sun .... Friday
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

#################################################
# Post view activity normalized for time since 
# publication. The pubDate is known by the path
# name.
#################################################

normHitsSincePub <- livePostHit %>%
  group_by(path) %>%
  arrange(date) %>%
  mutate(
    hitsSincePub = cumsum(hits),
    pubDate = as.Date(substr(path, 2, 11)),
    daysSincePub = as.integer(date - pubDate)
  )

normHitsSincePub %>% 
  slice_max(order_by = hitsSincePub, n=1) %>%
  ggplot(aes(x=daysSincePub, y=hitsSincePub)) +
    scale_x_sqrt() +
    geom_point() +
    ggtitle(paste("Days Since Pub vs Total Hits at Current Views as of", today()))



getMostRecentPosts <- function(n=NUM_MOST_RECENT_POSTS) {
  k <- data.frame(
    post_names = livePosts,
    pubDate = substr(livePosts, 2, 11)
  )
  k <- k %>% arrange(desc(pubDate)) %>% top_n(n)
  k$post_names
}



N_MOST_RECENT_POSTS <- getMostRecentPosts()
most_recent_posts_data <- normHitsSincePub %>%
  filter(path %in% N_MOST_RECENT_POSTS, daysSincePub < 366)

normHitsStdDev <- normHitsSincePub %>%
  complete(date = seq.Date(min(date), max(date), by="day")) %>%
  fill(hitsSincePub, pubDate) %>%
  mutate(daysSincePub = as.integer(date - pubDate)) %>%
  group_by(daysSincePub) %>%
  summarise(
    ymin = min(hitsSincePub),
    ymax = max(hitsSincePub),
    hsp_mean = mean(hitsSincePub),
    hsp_stdev = mad(hitsSincePub, center = mean(hitsSincePub)),
    cnt = n()
  )

normHitsStdDev %>%
  filter(daysSincePub < 31) %>%
  inner_join(most_recent_posts_data, by="daysSincePub") %>%
  ggplot(aes(x = daysSincePub, y = hitsSincePub)) +
    geom_line(aes(color=path)) +
    geom_point(aes(shape=path, color=path)) +
    geom_ribbon(aes(ymin=hsp_mean - hsp_stdev, ymax=hsp_mean + hsp_stdev), alpha=0.1) +
    ggtitle(paste(NUM_MOST_RECENT_POSTS, "Most Recent Posts and Performance in First 30 Days of Publication")) +
    theme(legend.position="bottom") +
    guides(colour = guide_legend(nrow = 3)) +
    coord_cartesian(xlim = c(0,31))


normHitsStdDev %>%
  filter(daysSincePub < 366) %>%
  left_join(most_recent_posts_data, by="daysSincePub") %>%
  ggplot(aes(x = daysSincePub, y = hitsSincePub)) +
    geom_line(aes(color=path)) +
    geom_point(aes(shape=path, color=path)) +
    geom_ribbon(aes(ymin=hsp_mean - hsp_stdev, ymax=hsp_mean + hsp_stdev), alpha=0.1) +
    ggtitle(paste(NUM_MOST_RECENT_POSTS, "Most Recent Posts and Performance in First Year of Publication")) +
    theme(legend.position="bottom") +
    guides(colour = guide_legend(nrow = 2)) +
    coord_cartesian(xlim=c(0,366))

# At the end of the first year of publication. What were the most viewed posts? Display them against the average views.
normHitsSincePub %>%
  filter(daysSincePub < 366) %>%
  group_by(path) %>%
  summarise(max_hits=max(hitsSincePub)) %>%
  arrange(-max_hits) %>%
  top_n(NUM_MOST_RECENT_POSTS) %>%
  inner_join(normHitsSincePub) %>%
  filter(daysSincePub < 366) %>%
  inner_join(normHitsStdDev) %>%
  ggplot(aes(x = daysSincePub, y = hitsSincePub)) +
    geom_line(aes(color=path)) +
    geom_point(aes(shape=path, color=path)) +
    geom_ribbon(aes(ymin=hsp_mean - hsp_stdev, ymax=hsp_mean + hsp_stdev), alpha=0.1) +
    ggtitle(paste("Hits of ", NUM_MOST_RECENT_POSTS, " most viewed posts in their first year")) +
    theme(legend.position="bottom") +
    guides(colour = guide_legend(nrow = 3)) +
    coord_cartesian(xlim=c(0,366))

    
