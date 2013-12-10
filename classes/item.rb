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

    @content[:type] = 'tweet'

    if tweet.retweet?
      # Keep the retweet's ID for replies and the time for sorting. We can reply
      # to a retweet and Twitter handles it, we don't have to reply to the
      # original tweet's ID.
      @content[:id] = tweet.attrs[:id_str]
      @content[:replytoid] = tweet.attrs[:id_str]
      @content[:time] = tweet.created_at

      # Add extra tags to show who retweeted it and when
      @content[:retweetedbyuser] = tweet.from_user
      @content[:retweetedbyusername] = tweet.user.name
      @content[:originalposttime] = tweet.retweeted_status.created_at
      @content[:isretweet] = tweet.retweet?

      # Copy the retweeted status's data into the main body
      @content[:escapedtext] = tweet.retweeted_status.full_text
      @content[:fromuser] = tweet.retweeted_status.from_user
      @content[:fromusername] = tweet.retweeted_status.user.name
      @content[:fromuseravatar] = tweet.retweeted_status.user.profile_image_url
      @content[:fromuserid] = tweet.retweeted_status.user.attrs[:id_str]
      @content[:isreply] = tweet.retweeted_status.reply?
      @content[:numfavourited] = tweet.retweeted_status.favoriters_count
      @content[:numretweeted] = tweet.retweeted_status.retweeters_count
      @content[:numreplied] = tweet.retweeted_status.repliers_count
      @content[:numfavourited] = tweet.retweeted_status.favoriters_count
      @content[:inreplytostatusid] = tweet.retweeted_status.attrs[:in_reply_to_status_id_str]
      @content[:inreplytouserid] = tweet.retweeted_status.in_reply_to_user_id
      populateURLsFromTwitter(tweet.retweeted_status.urls, tweet.retweeted_status.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.retweeted_status.user_mentions, tweet.retweeted_status.hashtags)

    else
      # Not a retweet, so populate the content of the item normally.
      @content[:escapedtext] = tweet.full_text
      @content[:id] = tweet.attrs[:id_str]
      @content[:replytoid] = tweet.attrs[:id_str]
      @content[:time] = tweet.created_at
      @content[:fromuser] = tweet.from_user
      @content[:fromusername] = tweet.user.name
      @content[:fromuseravatar] = tweet.user.profile_image_url
      @content[:fromuserid] = tweet.user.attrs[:id_str]
      @content[:isreply] = tweet.reply?
      @content[:isretweet] = tweet.retweet?
      @content[:numfavourited] = tweet.favoriters_count
      @content[:numretweeted] = tweet.retweeters_count
      @content[:numreplied] = tweet.repliers_count
      @content[:numfavourited] = tweet.favoriters_count
      @content[:inreplytostatusid] = tweet.attrs[:in_reply_to_status_id_str]
      @content[:inreplytouserid] = tweet.in_reply_to_user_id
      populateURLsFromTwitter(tweet.urls, tweet.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.user_mentions, tweet.hashtags)
    end
    
    # Permalink
    @content[:permalink] = 'https://twitter.com/' +  @content[:fromuser] + '/status/' + @content[:id]
    
    # Actions. Add in a nice order because the web UI displays buttons in this order.
    @content[:actions] = []
    # Can always reply
    @content[:actions] << {:name => 'reply', :method => 'POST', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :replytoid => @content[:replytoid]}}
    # Can view conversation if it's a reply
    if @content[:isreply]
      @content[:actions] << {:name => 'conversation', :method => 'GET', :path => '/thread', :params => {:service => @service, :uid => @fetchedforuserid, :postid => @content[:replytoid]}}
    end
    # Can't retweet your own tweets
    if @content[:fromuserid] != @fetchedforuserid
      @content[:actions] << {:name => 'retweet', :method => 'POST', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'retweet', :postid => @content[:replytoid]}}
    end
    # Can always favourite
    @content[:actions] << {:name => 'favorite', :method => 'POST', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'favorite', :postid => @content[:replytoid]}}
    # Can delete if it's yours
    if @content[:fromuserid] == @fetchedforuserid
      @content[:actions] << {:name => 'delete', :method => 'DELETE', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :postid => @content[:replytoid]}}
    end

		# Unescape HTML entities in text
		@content[:text] = HTMLEntities.new.decode(@content[:escapedtext])

    unshorten()
  end


  # Fills in the contents of the item based on a Facebook post.
  def populateFromFacebookPost (post)
  
    @content[:id] = post['id']
    @content[:type] = "facebook_#{post['type']}"
    if post.has_key?('from') && post['from'].is_a?(Hash)
      @content[:fromuserid] = post['from']['id']
      @content[:fromusername] = post['from']['name']
      @content[:fromuseravatar] = "http://graph.facebook.com/#{post['from']['id']}/picture"
    end
    if post.has_key?('comments')
      @content[:numcomments] = post['comments']['data'].length
      #@content[:comments] = post['comments']['data']
    else
      @content[:numcomments] = 0
    end
    if post.has_key?('likes')
      @content[:numlikes] = post['likes']['data'].length
      @content[:likes] = post['likes']['data']
    else
      @content[:numlikes] = 0
    end

    # Get some text for the item by any means necessary
    @content[:text] = ''
    if post.has_key?('message')
      @content[:text] = post['message']
    elsif post.has_key?('story')
      @content[:text] = post['story']
    elsif post.has_key?('title')
      @content[:text] = post['title']
    end

    # Detect notifications
    if post.has_key?('unread')
      @content[:unread] = post['unread']
      # Notifications are given their "updated" time so that if clients cache
      # objects, updates to the notification can be noticed and thus end up
      # at the top of the list.
      @content[:time] = Time.parse(post['updated_time'])
      if !post['object'].nil?
        @content[:sourceid] = post['object']['id']
        # When a client tries to reply to a notification, they should be replying
        # to the original post
        @content[:replytoid] = post['object']['id']
        # Permalink to the original post
        @content[:permalink] = 'https://facebook.com/' + post['object']['id']
      else
        # This is a notification about something, but the source item wasn't 
        # provided.
        @content[:sourceid] = nil
        @content[:replytoid] = nil
      end
      @content[:type] = 'facebook_notification'
    else
      # Non-notifications are given their "created" time and permalink
      @content[:time] = Time.parse(post['created_time'])
      @content[:permalink] = 'https://facebook.com/' + post['id']
      # Non-notifications can be replied to directly
      @content[:replytoid] = post['id']
      # Non-notifications might be 'to' someone else, e.g. a friend posting on another
      # friend's wall.
      if post.has_key?('to') && post['to'].is_a?(Hash) && post['to']['data'].is_a?(Array)
        @content[:tousername] = post['to']['data'][0]['name']
      end
    end

    # Populate URLs and embedded media
    populateURLsFromFacebook(post)
    
    # Actions.
    @content[:actions] = []
    # If Reply To ID is null, we don't really know what we're seeing here so can't
    # give any actions.
    if !@content[:replytoid].nil?
      # Everything with a Reply To ID can be commented on.
      @content[:actions] << {:name => 'reply', :method => 'POST', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :replytoid => @content[:replytoid]}}
      # Only items with comments or which are notifications have a conversation view
      if (@content[:numcomments] > 0) || (@content[:type] == 'facebook_notification')
        @content[:actions] << {:name => 'conversation', :method => 'GET', :path => '/thread', :params => {:service => @service, :uid => @fetchedforuserid, :postid => @content[:replytoid]}}
      end
      # Only non-notifications can be liked
      if (@content[:type] != 'facebook_notification')
        @content[:actions] << {:name => 'like', :method => 'POST', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'like', :postid => @content[:replytoid]}}
      end
      # Can delete if it's ours and not a notification
      if (@content[:type] != 'facebook_notification') && (@content[:fromuserid] == @fetchedforuserid)
        @content[:actions] << {:name => 'delete', :method => 'DELETE', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :postid => @content[:replytoid]}}
      end
    end
    
    # If we *still* have no post text at this point, try and get the title
    # of an included link.
    if (@content[:text] == '') && @content.has_key?(:links)
      @content[:text] = @content[:links][0][:title]
    end

		# Unescape HTML entities in text
		@content[:text] = HTMLEntities.new.decode(@content[:text])

  end


  # Fills in the contents of the item based on a Facebook comment.
  def populateFromFacebookComment (comment)
    @content[:type] = 'facebook_comment'
    @content[:id] = comment['id']
    @content[:time] = Time.parse(comment['created_time'])
    @content[:fromuserid] = comment['from']['id']
    @content[:fromusername] = comment['from']['name']
    @content[:fromuseravatar] = "http://graph.facebook.com/#{comment['from']['id']}/picture"
    @content[:text] = comment['message']
    
    # When a client tries to reply to a comment, they can reply to the comment's
    # own ID and Facebook will put it in the right place.
    @content[:replytoid] = comment['id']

		# Unescape HTML entities in text
		@content[:text] = HTMLEntities.new.decode(@content[:text])
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
    @content[:links] = finishedArray
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
    @content[:usernames] = usernameArray

    hashtagArray = []
    hashtags.each do |hashtag|
      hashtagArray << {:text => hashtag.text, :indices => hashtag.indices}
    end
    @content[:hashtags] = hashtagArray
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
    @content[:links] = finishedArray
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
          # Remove link start/end positions from the link object so that clients
          # don't try to tag a URL that is no longer there. Leave the rest of the
          # link metadata so clients can make a permalink to the Twixt page if they
          # like.
          link[:indices] = []
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
      
      # Catch URLs that are actually to an image even though they weren't given a
      # 'preview' block, and give them a preview
      imageURLMatch = ANY_IMAGE_URL_REGEX.match(link[:expanded_url])
      if imageURLMatch && !link.has_key?(:preview)
        link[:preview] = link[:expanded_url]
      end
    end
  end

end
