#!/usr/bin/env ruby
# encoding: UTF-8

# Item class for the SuccessWhale API. Represents a feed item, such as
# a status update or a reply.

class Item

  def initialize (service, fetchedforuserid)
    @service = service
    @fetchedforuserid = fetchedforuserid
    @content = {}
  end

  # Fills in the contents of the item based on a tweet.
  def populateFromTweet (tweet)

    if tweet.retweet?
      # Keep the retweet's ID for replies and the time for sorting
      @content.merge!(:id => tweet.attrs[:id_str])
      @content.merge!(:time => tweet.created_at)

      # Add extra tags to show who retweeted it and when
      @content.merge!(:retweetedbyuser => tweet.from_user)
      @content.merge!(:retweetedbyusername => tweet.user.name)
      @content.merge!(:originalposttime => tweet.retweeted_status.created_at)
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
      @content.merge!(:inreplytostatusid => tweet.retweeted_status.attrs[:in_reply_to_status_id_str])
      @content.merge!(:inreplytouserid => tweet.retweeted_status.in_reply_to_user_id)
      populateURLsFromTwitter(tweet.retweeted_status.urls, tweet.retweeted_status.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.retweeted_status.user_mentions, tweet.retweeted_status.hashtags)

    else
      # Not a retweet, so populate the content of the item normally.
      @content.merge!(:text => tweet.full_text)
      @content.merge!(:id => tweet.attrs[:id_str])
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
      @content.merge!(:inreplytostatusid => tweet.attrs[:in_reply_to_status_id_str])
      @content.merge!(:inreplytouserid => tweet.in_reply_to_user_id)
      populateURLsFromTwitter(tweet.urls, tweet.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.user_mentions, tweet.hashtags)
    end
  end


  # Fills in the contents of the item based on a Facebook post.
  def populateFromFacebookPost (post)

    @content.merge!(:id => post['id'])
    @content.merge!(:type => post['type'])
    @content.merge!(:time => Time.parse(post['created_time']))
    @content.merge!(:fromuserid => post['from']['id'])
    @content.merge!(:fromusername => post['from']['name'])
    @content.merge!(:fromuseravatar => "http://graph.facebook.com/#{post['from']['id']}/picture")
    if post.has_key?('comments')
      @content.merge!(:numcomments => post['comments']['count'])
      #@content.merge!(:comments => post['comments']['data'])
    else
      @content.merge!(:numcomments => 0)
    end
    if post.has_key?('likes')
      @content.merge!(:numlikes => post['likes']['count'])
      #@content.merge!(:likes => post['likes']['data'])
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

    # Detect notifications
    if post.has_key?('unread')
      @content.merge!(:unread => post['unread'])
      @content.merge!(:type => 'notification')
    end

    # Populate URLs and embedded media
    populateURLsFromFacebook(post)

  end


  # Fills in the extended contents of the item (comments and likes) based
  # on a Facebook post. Used when retrieving a thread, not a feed (feeds
  # do not carry this detailed information)
  def populateFacebookCommentsLikes (post)

    if post.has_key?('comments')
      @content.merge!(:comments => post['comments']['data'])
    end
    if post.has_key?('likes')
      @content.merge!(:likes => post['likes']['data'])
    end

  end


  # TODO: Populate from LinkedIn


  # Populates the "urls" array from Twitter data. This contains a set of
  # indices for the URL to help with linking, since on Twitter a URL is
  # part of the tweet text itself. Twitter's "media previews" are also
  # included.
  def populateURLsFromTwitter(urls, media)
    finishedArray = []
    urls.each do |url|
      finishedArray << {:url => url.url, :expanded_url => url.expanded_url,
       :title => url.display_url, :indices => url.indices}
    end
    media.each do |url|
      finishedArray << {
        :url => url.url, :expanded_url => url.expanded_url,
        :title => url.display_url, :preview => url.media_url,
        :indices => url.indices
      }
    end
    @content.merge!(:links => finishedArray)
  end

  # Populates the "usernames" and "hashtags" arrays from Twitter data.
  # This allows clients to more easily find usernames and hashtags and
  # deal with them however they like.
  def populateUsernamesAndHashtagsFromTwitter(usernames, hashtags)
    usernameArray = []
    usernames.each do |username|
      usernameArray << {:id => username.id, :user => username.screen_name,
       :indices => username.indices}
    end
    @content.merge!(:usernames => usernameArray)

    hashtagArray = []
    hashtags.each do |hashtag|
      hashtagArray << {:text => hashtag.text, :indices => hashtag.indices}
    end
    @content.merge!(:hashtags => hashtagArray)
  end

  # Populates the "urls" array from Facebook data. This does not contain
  # any indices to help with linking, because URLs attached to a Facebook
  # item are usually not replicated in the text, they're just extra.
  # I think there is only ever one URL attached to a Facebook post, but
  # we return an array to keep consistency with Twitter. Facebook's preview
  # thumbnails are included.
  def populateURLsFromFacebook(post)
    finishedArray = []
    if post.has_key?('link')
      urlitem = {}
      # TODO: URL expansion (the hard way)
      urlitem.merge!({:url => post['link'], :title => post['name']})
      if post.has_key?('picture')
        urlitem.merge!({:preview => post['picture']})
      end
      finishedArray << urlitem
    end
    @content.merge!(:links => finishedArray)
  end

  # Returns the item as a hash.
  def asHash
    return {:service => @service, :fetchedforuserid => @fetchedforuserid, :content => @content}
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
    text = @content[:text].force_encoding('UTF-8')
    for phrase in phrases
      if text.include? phrase
        return true
        break
      end
    end
    return false
  end
end