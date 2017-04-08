#!/usr/bin/env Rscript
# generates the graphs

library(ggplot2)
library(rjson)
library(reshape2)

articleViewCount <- data.frame(
  read.csv('articleViews.csv', header = FALSE))
postHitCount <- data.frame(
  read.csv('postHits.csv', header = FALSE))
postHitCount$V4 <- as.numeric(postHitCount$V2) / postHitCount$V3
postTags <- fromJSON(file = 'posttags.json')



articleViewsPlot <- ggplot(data=articleViewCount, aes(x=V1, y=V2)) +
  xlab('post title') + ylab('views') +
  ggtitle('Views of Each Post') +
  geom_bar(stat="identity") +
  theme(axis.text = element_text(angle=75, hjust = 1))

ggplot(data=postHitCount, aes(V3, fill = V1)) +
  xlab('tag name') + ylab('tag views') +
  ggtitle('Tag Views') +
  geom_bar(stat = 'identity') +
  theme(axis.text = element_text(angle = 75, hjust = 1))

hitTagsPerPostView <- ggplot(data=postHitCount, aes(x = V1, y = V4)) +
  xlab('tag name') + ylab('tag count / post count with tag') +
  ggtitle('Tag Hits / Post Views') +
  geom_bar(stat = 'identity') +
  theme(axis.text = element_text(angle = 75, hjust = 1))
  
  