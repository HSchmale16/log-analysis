# logAnalyze.R

library(rjson)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Load the post tags file
tags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(tags)

tags.freq <- data.frame(table(unlist(tags)))
tags.freq$v3 <- tags.freq$Freq / length(unlist(tags))
colnames(tags.freq) <- c('tag', 'cnt', 'pct')

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'hits')

livePostHit <- hitCounts[hitCounts$path %in% livePosts,]


# Create the count of the hits per tag.
tag.hits <- data.frame(row.names = c('tag','hits'),
                      stringsAsFactors = FALSE)
apply(livePostHit, 1, function(x) {
  for(tag in tags[x[1]]) {
    tag.hits <<- rbind(tag.hits,
                      data.frame(tag, as.numeric(x[2]),
                                 stringsAsFactors = FALSE))
  }
})

names(tag.hits) <- c('tag', 'hits')
# scan and sum the tags
tagHitsSum <- tag.hits %>%
  group_by(tag) %>%
  summarise(avg = mean(hits), tot = sum(hits))


# Plot the hits
ggplot(data=livePostHit, aes(x=path, y=hits)) +
  xlab('post title') + ylab('views') +
  ggtitle('Views of Each Post') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))
ggplot(data=tagHitsSum, aes(x=tag, y=avg)) +
  xlab('tag name') + ylab('views') +
  ggtitle('Views of Each Tag') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))
ggplot(data=tagHitsSum, aes(x="",y=tot,fill=tag)) +
  geom_bar(width = 1, stat='identity') +
  coord_polar()
  
