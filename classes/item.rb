#!/usr/bin/env ruby
# encoding: UTF-8

# Item class for the SuccessWhale API. Represents a feed item, such as
# a status update or a reply.

class Item

  def initialize ()
    @service = :twitter
    @content = {}
    @actions = {}
  end

  # Fills in the contents of the item based on a tweet.
  def populateFromTweet (tweet)
    @content.merge!(:text => tweet.full_text)
    @content.merge!(:id => tweet.id)
    @content.merge!(:time => tweet.created_at)
    @content.merge!(:fromuser => tweet.from_user)
    @content.merge!(:fromusername => tweet.user.name)
    @content.merge!(:fromuseravatar => tweet.user.profile_image_url)
    @content.merge!(:isreply => tweet.reply?)
    @content.merge!(:isretweet => tweet.retweet?)
    @content.merge!(:numfavourited => tweet.favoriters_count)
    @content.merge!(:numretweeted => tweet.retweeters_count)
    @content.merge!(:numreplied => tweet.repliers_count)
    @content.merge!(:numfavourited => tweet.favoriters_count)
    @content.merge!(:inreplytostatusid => tweet.in_reply_to_status_id)
    @content.merge!(:inreplytouserid => tweet.in_reply_to_user_id)

    if tweet.retweet?
      @content.merge!(:retweet => {})
      @content[:retweet].merge!(:text => tweet.retweeted_status.full_text)
      @content[:retweet].merge!(:id => tweet.retweeted_status.id)
      @content[:retweet].merge!(:time => tweet.retweeted_status.created_at)
      @content[:retweet].merge!(:fromuser => tweet.retweeted_status.from_user)
      @content[:retweet].merge!(:fromusername => tweet.retweeted_status.user.name)
      @content[:retweet].merge!(:fromuseravatar => tweet.retweeted_status.user.profile_image_url)
      @content[:retweet].merge!(:isreply => tweet.retweeted_status.reply?)
      @content[:retweet].merge!(:isretweet => tweet.retweeted_status.retweet?)
      @content[:retweet].merge!(:numfavourited => tweet.retweeted_status.favoriters_count)
      @content[:retweet].merge!(:numretweeted => tweet.retweeted_status.retweeters_count)
      @content[:retweet].merge!(:numreplied => tweet.retweeted_status.repliers_count)
      @content[:retweet].merge!(:numfavourited => tweet.retweeted_status.favoriters_count)
      @content[:retweet].merge!(:inreplytostatusid => tweet.retweeted_status.in_reply_to_status_id)
      @content[:retweet].merge!(:inreplytouserid => tweet.retweeted_status.in_reply_to_user_id)
    end

    processText

    # TODO: fill in actions
  end

  # Returns the item as a hash.
  def asHash
    return {:service => @service, :content => @content, :actions => @actions}
  end

  # Gets the time that the item was originally posted.  Used to sort
  # feeds by time.
  def getTime
    return @content[:time]
  end

  # Gets the text of the post.  Used to determine whether the text includes
  # a phrase in the user's blocklist.
  def getText
    if @content.has_key?('isretweet') && @content['isretweet'] == true
      return @content['retweet']['text']
    else
      return @content['text']
    end
  end

  # Process the text in the item, linking up URLs, @users and #hashtags.
  def processText
    # TODO
  end
end