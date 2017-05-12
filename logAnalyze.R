# logAnalyze.R

library(rjson)
library(ggplot2)
library(dplyr)
library(gridExtra)

# Load the post tags file
postTags <- rjson::fromJSON(file = 'posttags.json')
livePosts <- names(postTags)

# Load the Hit Counts
hitCounts <- read.csv(file = 'articleViews.csv', header = FALSE)
names(hitCounts) <- c('path', 'hits')

livePostHit <- hitCounts[hitCounts$path %in% livePosts,]


# Create the count of the hits per tag.
tagHits <- data.frame(row.names = c('tag','hits'),
                      stringsAsFactors = FALSE)
apply(livePostHit, 1, function(x) {
  for(tag in postTags[x[1]]) {
    tagHits <<- rbind(tagHits,
                      data.frame(tag, as.numeric(x[2]),
                                 stringsAsFactors = FALSE))
  }
})
names(tagHits) <- c('tag', 'hits')
# scan and sum the tags
tagHitsSum <- tagHits %>%
  group_by(tag) %>%
  summarise(hits = mean(hits))


# Plot the hits
ggplot(data=livePostHit, aes(x=path, y=hits)) +
  xlab('post title') + ylab('views') +
  ggtitle('Views of Each Post') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))
ggsave('posthits.pdf')
ggplot(data=tagHitsSum, aes(x=tag, y=hits)) +
  xlab('tag name') + ylab('views') +
  ggtitle('Views of Each Post') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))
ggsave('taghits.pdf')
