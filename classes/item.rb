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

    if tweet.retweet?
      # Keep the retweet's ID for replies and the time for sorting
      @content.merge!(:id => tweet.id)
      @content.merge!(:time => tweet.created_at)

      # Add extra tags to show who retweeted it and when
      @content.merge!(:retweetedbyuser => tweet.from_user)
      @content.merge!(:retweetedbyusername => tweet.user.name)
      @content.merge!(:retweetedat => tweet.created_at)
      @content.merge!(:isretweet => tweet.retweet?)

      # Copy the retweeted status's data into the main body
      @content.merge!(:text => tweet.retweeted_status.full_text)
      @content.merge!(:fromuser => tweet.retweeted_status.from_user)
      @content.merge!(:fromusername => tweet.retweeted_status.user.name)
      @content.merge!(:fromuseravatar => tweet.retweeted_status.user.profile_image_url)
      @content.merge!(:isreply => tweet.retweeted_status.reply?)
      @content.merge!(:numfavourited => tweet.retweeted_status.favoriters_count)
      @content.merge!(:numretweeted => tweet.retweeted_status.retweeters_count)
      @content.merge!(:numreplied => tweet.retweeted_status.repliers_count)
      @content.merge!(:numfavourited => tweet.retweeted_status.favoriters_count)
      @content.merge!(:inreplytostatusid => tweet.retweeted_status.in_reply_to_status_id)
      @content.merge!(:inreplytouserid => tweet.retweeted_status.in_reply_to_user_id)
      @content.merge!(:urls => tweet.retweeted_status.urls)

    else
      # Not a retweet, so populate the content of the item normally.
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
      @content.merge!(:urls => tweet.urls)
    end

    # TODO: fill in actions
  end

  # TODO: Populate from Facebook
  # TODO: Populate from LinkedIn

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

  # Check if the text in the item contains any of the phrases in the list
  # provided. Used in the feed API for removing items that match phrases in
  # a user's banned phrases list.
  def matchesPhrase(phrases)
    for phrase in phrases
      if @content[:text].include? phrase
        return false
      end
    end
    return false
  end
end