# TwitterDataAnalysis
Analyze the content of Twitter posts and categories them into positive, neutral and negative posts.


### Implementation:
Firstly, for implementation of this project, we have maintained two text files namely, positive and negative, containing respective words to segregate the tweets as positive, negative or neutral. Next, we need to import packages for implementing our project. For accessing the tweets we need to use the Twitter’s API. For this we have imported packages such as: 
  * twitteR- this provides an interface to the Twitter Web API.
  * ROAuth- R interface for OAuth, which is used for authenticating the user via OAuth for web services.
  
For analyzing the data and clustering it, we have imported the following packages:
  * plyr- used for combining, applying and splitting data.
  * dplyr- this is used for working with data frame like objects, both in memory and out of memory.
  * stringr- used for common string operations.
  * ggplot2- used to plot the data in graphs (data visualization).
  

A twitter account was created for authenticating and accessing twitter posts. The authentication is done by requesting and verifying the token, provided for the created account, and obtaining the consumer keys and comparing it with the help of methods from ROAuth. 

After the authentication procedure is complete, a random 1500 tweets for a particular word (in our project we have considered “Hillary” and “Barak Obama”) are obtained for analyzation. The tweets are also tabulated in the document with details such as, the time when it was created, its id, the profile name, the number of retweets on that post and the source (hyperlink) of the tweet.  

As we are maintaining the latest records, the previous records from the cumulative file are viewed and the duplicate records are deleted to avoid redundancies of the tweets. 

Every sentence from the particular tweet is analyzed by comparing the words in the sentence with the predefined words in the positive and negative text files. Here, we are using stringr for performing the string operations. A count of the positive words is maintained by going through each word and comparing it with the words from the file. The count is incremented after each finding of positive words. The same things is done for the negative words. Then, a score is maintained by subtracting the count of the positive words with the count of the negative words. 
If the obtained score is positive, the tweet is considered to be positive and if it is negative the respective tweet is a negative one. Neutral tweets are the ones whose obtained score is zero. This result is also tabulated in the cumulative file.

At the end, we have plotted the obtained result in the form of a graph. The tweets represented are for specific days.

