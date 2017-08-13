#connect all libraries
library(twitteR)
library(ROAuth)
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)


download.file(url='http://curl.haxx.se/ca/cacert.pem', destfile='cacert.pem')
reqURL <- 'https://api.twitter.com/oauth/request_token'
accessURL <- 'https://api.twitter.com/oauth/access_token'
authURL <- 'https://api.twitter.com/oauth/authorize'
consumerKey <- 'PUT_YOUR_CONSUMER_KEY' #put the Consumer Key from Twitter Application
consumerSecret <- 'PUT_YOUR_CONSUMER_SECRET'  #put the Consumer Secret from Twitter Application

Cred <- OAuthFactory$new(consumerKey=consumerKey, consumerSecret=consumerSecret,
                         requestURL=reqURL, accessURL=accessURL, authURL=authURL)

Cred$handshake(cainfo="cacert.pem")
save(Cred, file="twitter_authentication.Rdata")
load('twitter authentication.Rdata') 

setup_twitter_oauth(consumerKey, cosumerSecret, 'YOUR_ACCESS_TOKEN','YOUR_ACCESS_SECRET')

search <- function(searchterm)
{
  #access tweets and create cumulative file
  list <- searchTwitter(searchterm, n=1500)
  df <- twListToDF(list)
  df <- df[, order(names(df))]
  df$created <- strftime(df$created, '%Y-%m-%d-%H:%M:%S')
  if (file.exists(paste(searchterm, '_stack.csv'))==FALSE) write.csv(df, file=paste(searchterm, '_stack.csv'), row.names=F)
  
  #merge last access with cumulative file and remove duplicates
  stack <- read.csv(file=paste(searchterm, '_stack.csv'))
  stack <- rbind(stack, df)
  stack <- subset(stack, !duplicated(stack$text))
  write.csv(stack, file=paste(searchterm, '_stack.csv'), row.names=F)
  
  #evaluation tweets function
  score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
  {
    require(plyr)
    require(stringr)
    scores <- laply(sentences, function(sentence, pos.words, neg.words){
      sentence <- gsub('[[:punct:]]', "", sentence)
      sentence <- gsub('[[:cntrl:]]', "", sentence)
      sentence <- gsub('\\d+', "", sentence)
      sentence=str_replace_all(sentence,"[^[:graph:]]", " ") 
      sentence <- tolower(sentence)
      word.list <- str_split(sentence, '\\s+')
      words <- unlist(word.list)
      pos.matches <- match(words, pos.words)
      neg.matches <- match(words, neg.words)
      pos.matches <- !is.na(pos.matches)
      neg.matches <- !is.na(neg.matches)
      score <- sum(pos.matches) - sum(neg.matches)
      return(score)
    }, pos.words, neg.words, .progress=.progress)
    scores.df <- data.frame(score=scores, text=sentences)
    return(scores.df)
  }
  
  pos <- scan('/path/to/positive-words.txt', what='character', comment.char=';') #folder with positive dictionary
  neg <- scan('/path/to/negative-words.txt', what='character', comment.char=';') #folder with negative dictionary
  pos.words <- c(pos)
  neg.words <- c(neg)
  Dataset <- stack
  Dataset$text <- as.factor(Dataset$text)
  
  scores <- score.sentiment(Dataset$text, pos.words, neg.words, .progress='text')
  write.csv(scores, file=paste(searchterm, '_scores.csv'), row.names=TRUE) #save evaluation results into the file
  
  #total evaluation: positive / negative / neutral
  stat <- scores
  stat$created <- stack$created
  stat$created <- as.Date(stat$created)
  stat <- mutate(stat, tweet=ifelse(stat$score > 0, 'positive', ifelse(stat$score < 0, 'negative', 'neutral')))
  group.tweet <- group_by(stat, tweet, created)
  group.tweet <- summarise(by.tweet, number=n())
  write.csv(group.tweet, file=paste(searchterm, '_opinion.csv'), row.names=TRUE)
  
  #create chart
  ggplot(by.tweet, aes(created, number)) + geom_line(aes(group=tweet, color=tweet), size=2) +
    geom_point(aes(group=tweet, color=tweet), size=4) +
    theme(text = element_text(size=18), axis.text.x = element_text(angle=90, vjust=1)) +
    ggtitle(searchterm)
    
  ggsave(file=paste(searchterm, '_plot.jpeg'))
}

search("Donald Trump")
