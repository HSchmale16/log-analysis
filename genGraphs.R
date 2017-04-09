#!/usr/bin/env Rscript
# generates the graphs

library(ggplot2)
library(rjson)
library(reshape2)

# load the views of each article
articleViewCount <- data.frame(
  read.csv('articleViews.csv', header = FALSE))

# load postHitCount or the popularity of tag hits with usage
postHitCount <- data.frame(
  read.csv('postHits.csv', header = FALSE))
postHitCount$HitsVUse <- as.numeric(postHitCount$V2) / postHitCount$V3
names(postHitCount) <- c('tagname', 'hitcnt', 'usecnt', 'usevhit')


# load the post tags file, as it contains all of the tags
articleTags <- fromJSON(file = 'posttags.json')


# Plot the actual views of each article
articleViewsPlot <- ggplot(data=articleViewCount, aes(x=V1, y=V2)) +
  xlab('post title') + ylab('views') +
  ggtitle('Views of Each Post') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))

# Plot the use of tags of articles
df <- melt(postHitCount)
ggplot(df, aes(x = tagname, y = value)) +
  geom_bar(aes(fill = variable),stat = "identity",position = "dodge") +
  scale_y_log10() +
  theme(axis.text = element_text(angle=75, hjust = 1))



hitTagsPerPostView <- ggplot(data=postHitCount, aes(x=tagname, y = usevhit)) +
  xlab('tag name') + ylab('tag count / post count with tag') +
  ggtitle('Tag Hits / Post Views') +
  geom_bar(stat = 'identity') +
  theme(axis.text = element_text(angle = 75, hjust = 1))
  
  