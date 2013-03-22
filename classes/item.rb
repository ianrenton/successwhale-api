#!/usr/bin/env ruby
# encoding: UTF-8

# Item class for the SuccessWhale API. Represents a feed item, such as
# a status update or a reply.

class Item

  def initialize ()
    @service = ''
    @content = {}
    @actions = {}
  end

  # Fills in the contents of the item based on a tweet.
  def populateFromTweet (tweet)

    @service = :twitter

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


  # Fills in the contents of the item based on a Facebook post.
  def populateFromFacebookPost (post)

    @service = :facebook

    @content.merge!(:id => post['id'])
    @content.merge!(:type => post['type'])
    @content.merge!(:time => post['created_time'])
    @content.merge!(:fromuserid => post['from']['id'])
    @content.merge!(:fromusername => post['from']['name'])
    @content.merge!(:fromuseravatar => "http://graph.facebook.com/#{post['from']['id']}/picture")
    if post.has_key?('comments')
      @content.merge!(:numcomments => post['comments']['count'])
      @content.merge!(:comments => post['comments']['data'])
    else
      @content.merge!(:numcomments => 0)
    end
    if post.has_key?('likes')
      @content.merge!(:numlikes => post['likes']['count'])
      @content.merge!(:likes => post['likes']['data'])
    else
      @content.merge!(:numlikes => 0)
    end

    # Get some text for the item by any means necessary
    @content.merge!(:text => '')
    if post.has_key?('message')
      @content.merge!(:text => post['message'])
    elsif post.has_key?('story')
      @content.merge!(:text => post['story'])
    elsif post.has_key?('title')
      @content.merge!(:text => post['title'])
    end

    if post.has_key?('link')
      @content.merge!(:haslink => true)
      @content.merge!(:linkurl => post['link'])
      @content.merge!(:linktitle => post['name'])
    else
      @content.merge!(:haslink => false)
    end

    # Detect notifications
    if post.has_key?('unread')
      @content.merge!(:unread => post['unread'])
      @content.merge!(:type => 'notification')
    end

    # TODO: fill in actions
  end


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