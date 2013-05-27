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

    @content.merge!(:type => 'tweet')

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

    unshorten()
  end


  # Fills in the contents of the item based on a Facebook post.
  def populateFromFacebookPost (post)

    @content.merge!(:id => post['id'])
    @content.merge!(:type => "facebook_#{post['type']}")
    @content.merge!(:time => Time.parse(post['created_time']))
    @content.merge!(:fromuserid => post['from']['id'])
    @content.merge!(:fromusername => post['from']['name'])
    @content.merge!(:fromuseravatar => "http://graph.facebook.com/#{post['from']['id']}/picture")
    if post.has_key?('comments')
      @content.merge!(:numcomments => post['comments']['data'].length)
      #@content.merge!(:comments => post['comments']['data'])
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

    # Detect notifications
    if post.has_key?('unread')
      @content.merge!(:unread => post['unread'])
      if !post['object'].nil?
        @content.merge!(:sourceid => post['object']['id'])
      end
      @content.merge!(:type => 'facebook_notification')
    end

    # Populate URLs and embedded media
    populateURLsFromFacebook(post)

  end


  # Fills in the contents of the item based on a Facebook comment.
  def populateFromFacebookComment (comment)
    @content.merge!(:type => 'facebook_comment')
    @content.merge!(:id => comment['id'])
    @content.merge!(:time => Time.parse(comment['created_time']))
    @content.merge!(:fromuserid => comment['from']['id'])
    @content.merge!(:fromusername => comment['from']['name'])
    @content.merge!(:fromuseravatar => "http://graph.facebook.com/#{comment['from']['id']}/picture")
    @content.merge!(:text => comment['message'])
  end


  # TODO: Populate from LinkedIn


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
    return @content['text']
  end

  # Returns the type
  def getType()
    return @content[:type]
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
    finishedArray = addExtraPreviews(finishedArray)
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
        # Horrible hack to get large size previews
        if post['picture'].include?('_s.jpg')
          urlitem.merge!({:preview => post['picture'].gsub('_s.jpg', '_n.jpg')}) 
        else
          urlitem.merge!({:preview => post['picture']})
        end
      end
      finishedArray << urlitem
    end
    @content.merge!(:links => finishedArray)
  end

  # Unshortens a tweet, if it can be detected that it has been previously
  # shortened by a service such as Twixt or TwitLonger.
  def unshorten()
    @content[:links].each do |link|
      unless link[:expanded_url].nil?
        if link[:expanded_url].include?(TWIXT_URL_MATCHER)
          # This tweet has been shortened, so grab the real text
          source = Net::HTTP.get(URI(link[:expanded_url]))
          doc = Nokogiri::HTML(source)
          # Only one p element in a Twixt output, just find and use it.
          doc.xpath('//p').each do |p|
            @content[:text] = p.content
          end
        end
      end
    end
  end

  # Adds image previews for certain services that don't by default. e.g.
  # for maybe-political reasons Twitter presents Instagram links without
  # previews of the picture. This fixes that.
  def addExtraPreviews(links)
    links.each do |link|
      # Check for Instagram URLs
      instagramMatch = INSTAGRAM_URL_REGEX.match(link[:expanded_url])
      if instagramMatch
        # Add /media/ to the end to get a direct link, but this is a redirect
        # so follow it and return the real URL
        url = "#{link[:expanded_url]}media/"
        r = Net::HTTP.get_response(URI(url))
        if r.code == "302"
          link[:preview] = r.header['location']
        else
          link[:preview] = url
        end
      end

      # Check for Twitpic URLs
      twitpicMatch = TWITPIC_URL_REGEX.match(link[:expanded_url])
      if twitpicMatch
        # Convert to a Twitpic thumbnail. Only 150x150, but it's the best we can
        # legitimately get.
        url = "http://twitpic.com/show/thumb/#{twitpicMatch[1]}.jpg"
        r = Net::HTTP.get_response(URI(url))
        if r.code == "302"
          link[:preview] = r.header['location']
        else
          link[:preview] = url
        end
      end

      # Check for imgur URLs
      imgurMatch = IMGUR_URL_REGEX.match(link[:expanded_url])
      if imgurMatch
        # Convert to an imgur thumbnail. The extra "l" is not a typo, this
        # generates the 'large' thumbnail rather than the (even larger)
        # original image.
        link[:preview] = "http://i.imgur.com/#{imgurMatch[1]}l.jpg"
      end
    end
  end

end
