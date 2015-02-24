#!/usr/bin/env ruby
# encoding: UTF-8

# Item class for the SuccessWhale API. Represents a feed item, such as
# a status update or a reply.

class Item

  def initialize (service, fetchedforuserid, fetchedforuser)
    @service = service
    @fetchedforuserid = fetchedforuserid
    @fetchedforuser = fetchedforuser
    @content = {}
  end

  # Fills in the contents of the item based on a tweet.
  def populateFromTweet (tweet)

    if tweet.is_a?(Twitter::DirectMessage)
      # Check for DMs separately as these don't have the same fields as everything else
      @content[:type] = 'twitter_dm'
      @content[:escapedtext] = tweet.full_text
      @content[:id] = tweet.attrs[:id_str]
      @content[:replytoid] = tweet.attrs[:id_str]
      @content[:time] = tweet.created_at
      @content[:fromuser] = tweet.attrs[:sender_screen_name]
      @content[:fromusername] = tweet.sender.attrs[:name]
      @content[:fromuseravatar] = tweet.sender.attrs[:profile_image_url_https]
      @content[:fromuserid] = tweet.attrs[:sender_id_str]
      @content[:touser] = tweet.attrs[:recipient_screen_name]
      @content[:tousername] = tweet.recipient.attrs[:name]
      @content[:touseravatar] = tweet.recipient.attrs[:profile_image_url_https]
      @content[:touserid] = tweet.attrs[:recipient_id_str]
      @content[:links] = {}
    
    elsif tweet.retweet?
      @content[:type] = 'tweet'
      # Keep the retweet's ID for replies and the time for sorting. We can reply
      # to a retweet and Twitter handles it, we don't have to reply to the
      # original tweet's ID.
      @content[:id] = tweet.attrs[:id_str]
      @content[:replytoid] = tweet.attrs[:id_str]
      @content[:time] = tweet.created_at

      # Add extra tags to show who retweeted it and when
      @content[:retweetedbyuser] = tweet.user.screen_name
      @content[:retweetedbyusername] = tweet.user.name
      @content[:retweetedbyuserid] = tweet.user.attrs[:id_str]
      @content[:originalposttime] = tweet.retweeted_status.created_at
      @content[:isretweet] = tweet.retweet?

      # Copy the retweeted status's data into the main body
      @content[:escapedtext] = tweet.retweeted_status.full_text
      @content[:fromuser] = tweet.retweeted_status.user.screen_name
      @content[:fromusername] = tweet.retweeted_status.user.name
      @content[:fromuseravatar] = tweet.retweeted_status.user.attrs[:profile_image_url_https]
      @content[:fromuserid] = tweet.retweeted_status.user.attrs[:id_str]
      @content[:isreply] = tweet.retweeted_status.reply?
      @content[:numfavourited] = tweet.retweeted_status.favorite_count
      @content[:numretweeted] = tweet.retweeted_status.retweet_count
      @content[:inreplytostatusid] = tweet.retweeted_status.attrs[:in_reply_to_status_id_str]
      @content[:inreplytouserid] = tweet.retweeted_status.in_reply_to_user_id
      @content[:favorited] = tweet.retweeted_status.favorited
      @content[:permalink] = 'https://twitter.com/' +  @content[:fromuser] + '/status/' + @content[:id]
      populateURLsFromTwitter(tweet.retweeted_status.urls, tweet.retweeted_status.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.retweeted_status.user_mentions, tweet.retweeted_status.hashtags)

    else
      @content[:type] = 'tweet'
      # Not a retweet, so populate the content of the item normally.
      @content[:escapedtext] = tweet.full_text
      @content[:id] = tweet.attrs[:id_str]
      @content[:replytoid] = tweet.attrs[:id_str]
      @content[:time] = tweet.created_at
      @content[:fromuser] = tweet.user.screen_name
      @content[:fromusername] = tweet.user.name
      @content[:fromuseravatar] = tweet.user.attrs[:profile_image_url_https]
      @content[:fromuserid] = tweet.user.attrs[:id_str]
      @content[:isreply] = tweet.reply?
      @content[:isretweet] = tweet.retweet?
      @content[:numfavourited] = tweet.favorite_count
      @content[:numretweeted] = tweet.retweet_count
      @content[:inreplytostatusid] = tweet.attrs[:in_reply_to_status_id_str]
      @content[:inreplytouserid] = tweet.in_reply_to_user_id
      @content[:favorited] = tweet.favorited
      @content[:permalink] = 'https://twitter.com/' +  @content[:fromuser] + '/status/' + @content[:id]
      populateURLsFromTwitter(tweet.urls, tweet.media)
      populateUsernamesAndHashtagsFromTwitter(tweet.user_mentions, tweet.hashtags)
    end
    
    # Actions. Add in a nice order because the web UI displays buttons in this order.
    @content[:actions] = []
    # Can always reply
    @content[:actions] << {:name => 'reply', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :replytoid => @content[:replytoid]}}
    # Can view conversation if it's a reply
    if @content[:isreply]
      @content[:actions] << {:name => 'conversation', :path => '/thread', :params => {:service => @service, :uid => @fetchedforuserid, :postid => @content[:replytoid]}}
    end
    # Can't retweet your own tweets, retweets, or DMs
    if !((@content[:fromuserid] == @fetchedforuserid) || (@content[:retweetedbyuserid] == @fetchedforuserid)  || tweet.is_a?(Twitter::DirectMessage))
      @content[:actions] << {:name => 'retweet', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'retweet', :postid => @content[:replytoid]}}
    end
    # Can't favourite DMs or already favourited things
    if !(tweet.is_a?(Twitter::DirectMessage) || @content[:favorited])
      @content[:actions] << {:name => 'favorite', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'favorite', :postid => @content[:replytoid]}}
    end
    # Can un-favourite favourited things
    if @content[:favorited]
      @content[:actions] << {:name => 'unfavorite', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'unfavorite', :postid => @content[:replytoid]}}
    end
    # Can delete if it's yours
    if @content[:fromuserid] == @fetchedforuserid
      @content[:actions] << {:name => 'delete', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'delete', :postid => @content[:replytoid]}}
    elsif @content[:retweetedbyuserid] == @fetchedforuserid
      @content[:actions] << {:name => 'delete', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'delete', :postid => @content[:replytoid]}}
    end

    # Unescape HTML entities in text
    @content[:text] = HTMLEntities.new.decode(@content[:escapedtext])

    unshorten()
  end


  # Fills in the contents of the item based on a Facebook post.
  # Require the facebook client to fetch full size pictures instead of
  # thumbnails.
  def populateFromFacebookPost (post, facebookClient)
  
    @content[:id] = post['id']
    @content[:type] = "facebook_#{post['type']}"
    if post['from'] && post['from'].is_a?(Hash)
      @content[:fromuserid] = post['from']['id']
      @content[:fromusername] = post['from']['name']
      @content[:fromuseravatar] = "https://graph.facebook.com/#{post['from']['id']}/picture"
    end
    if post['comments']
      @content[:numcomments] = post['comments']['data'].length
      #@content[:comments] = post['comments']['data']
    else
      @content[:numcomments] = 0
    end
    if post['likes']
      @content[:numlikes] = post['likes']['data'].length
      @content[:likes] = post['likes']['data']
      @content[:liked] = !post['likes']['data'].select{|x| x['id'] == @fetchedforuserid}.empty?
    else
      @content[:numlikes] = 0
      @content[:liked] = false
    end

    # Get some text for the item by any means necessary
    @content[:text] = ''
    if post['message']
      @content[:text] = post['message']
    elsif post['story']
      @content[:text] = post['story']
    elsif post['title']
      @content[:text] = post['title']
    end

    # Detect notifications
    if post['unread']
      @content[:unread] = post['unread']
      # Notifications are given their "updated" time so that if clients cache
      # objects, updates to the notification can be noticed and thus end up
      # at the top of the list.
      @content[:time] = Time.parse(post['updated_time'])
      # Permalink to the original post
      @content[:permalink] = post['link']
      if !post['object'].nil?
        @content[:sourceid] = post['object']['id']
        # When a client tries to reply to a notification, they should be replying
        # to the original post
        @content[:replytoid] = post['object']['id']
      else
        # This is a notification about something, but the source item wasn't 
        # provided, so we don't know how to fill in these fields.
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
      if post['to'] && post['to'].is_a?(Hash) && post['to']['data'].is_a?(Array)
        @content[:tousername] = post['to']['data'][0]['name']
      end
    end

    # Populate URLs and embedded media
    populateURLsFromFacebook(post, facebookClient)
    
    # Actions.
    @content[:actions] = []
    # Everything with a Reply To ID can be commented on.
    if !@content[:replytoid].nil?
      @content[:actions] << {:name => 'reply', :path => '/item', :params => {:service => @service, :uid => @fetchedforuserid, :replytoid => @content[:replytoid]}}
    end
    # Only non-notifications can be liked
    if (@content[:type] != 'facebook_notification')
      # Like if not liked yet, dislike if already liked
      if @content[:liked]
        @content[:actions] << {:name => 'unlike', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'unlike', :postid => @content[:replytoid]}}
      else
        @content[:actions] << {:name => 'like', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'like', :postid => @content[:replytoid]}}
      end
    end
    # Can delete if it's ours and not a notification
    if (@content[:type] != 'facebook_notification') && (@content[:fromuserid] == @fetchedforuserid)
      @content[:actions] << {:name => 'delete', :path => '/actions', :params => {:service => @service, :uid => @fetchedforuserid, :action => 'delete', :postid => @content[:replytoid]}}
    end
    # Only items with comments or which are notifications have a conversation view
    if (@content[:numcomments] > 0) || (@content[:type] == 'facebook_notification')
      id = @content[:replytoid]
      if !id
        id = @content[:id]
      end
      @content[:actions] << {:name => 'conversation', :path => '/thread', :params => {:service => @service, :uid => @fetchedforuserid, :postid => id}}
    end
    
    # If we *still* have no post text at this point, try and get the title
    # of an included link.
    if (@content[:text] == '') && @content[:links] && @content[:links][0] && @content[:links][0][:title]
      @content[:text] = @content[:links][0][:title]
    end

    # Unescape HTML entities in text
    @content[:escapedtext] = @content[:text]
    @content[:text] = HTMLEntities.new.decode(@content[:text])

  end


  # Fills in the contents of the item based on a Facebook comment.
  def populateFromFacebookComment (comment)
    @content[:type] = 'facebook_comment'
    @content[:id] = comment['id']
    @content[:time] = Time.parse(comment['created_time'])
    @content[:fromuserid] = comment['from']['id']
    @content[:fromusername] = comment['from']['name']
    @content[:fromuseravatar] = "https://graph.facebook.com/#{comment['from']['id']}/picture"
    @content[:escapedtext] = comment['message']
    
    # When a client tries to reply to a comment, they can reply to the comment's
    # own ID and Facebook will put it in the right place.
    @content[:replytoid] = comment['id']

    # Unescape HTML entities in text
    @content[:text] = HTMLEntities.new.decode(@content[:escapedtext])
  end


  # Returns the item as a hash.
  def asHash
    return {:service => @service, :fetchedforuserid => @fetchedforuserid, :fetchedforuser => @fetchedforuser, :content => @content}
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
  # a user's banned phrases list. Phrases beginning with "/" are treated as
  # regexes (the initial "/" and any trailing "/" are not part of the regex).
  def matchesPhrase(phrases)
    text = @content[:text].force_encoding('UTF-8')
    for phrase in phrases
      if phrase.start_with? '/'
        if phrase.end_with? '/'
          phrase = phrase[0..-2]
        end
        rex = Regexp.new(phrase[1..-1])
        if rex.match text
          return true
        end
      else
        if text.include? phrase
          return true
        end
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
      finishedArray << {:url => url.attrs[:url], :expanded_url => url.attrs[:expanded_url],
       :title => url.display_url, :indices => url.indices}
    end
    media.each do |url|
      finishedArray << {
        :url => url.attrs[:url], :expanded_url => url.attrs[:expanded_url],
        :title => url.display_url, :preview => url.attrs[:media_url_https],
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
       :username => username.name, :indices => username.indices}
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
  # Require the facebook client to fetch full size pictures instead of
  # thumbnails.
  def populateURLsFromFacebook(post, facebookClient)
    finishedArray = []
    if post['link']
      urlitem = {}
      # TODO: URL expansion (the hard way)
      urlitem.merge!({:url => post['link'], :title => post['name']})
      if post['picture']
        # Don't use the URL from post['picture'] as it's a tiny preview, get
        # the full size picture for this post instead if we can get it
        if post['object_id']
          # This is a picture in someone's Facebook album
          begin
            # Try to get it properly
            fullSizeURL = facebookClient.get_picture(post['object_id'])
            urlitem.merge!({:preview => fullSizeURL})
          rescue
            # Otherwise, just revert to using the thumbnail
            urlitem.merge!({:preview => post['picture']})
          end
        else
          pictureURLParams = CGI::parse(post['picture'])
          if pictureURLParams['url'] && !pictureURLParams['url'].empty? 
            # This is a picture from a third-party site
            urlitem.merge!({:preview => URI.unescape(pictureURLParams['url'][0])})
          else
            # No idea what it is, just use what Facebook gives us and hope
            # for the best
            urlitem.merge!({:preview => post['picture']})
          end
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
            @content[:escapedtext] = HTMLEntities.new.encode(p.content)
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
        # Convert to an instagram thumbnail. The URL usually resolves to a redirect
        # so follow it and return the real URL
        url = "http://instagram.com/p/#{instagramMatch[1]}/media/"
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
        link[:preview] = "http://i.imgur.com/#{imgurMatch[2]}l.jpg"
      end
      
      # Catch URLs that are actually to an image even though they weren't given a
      # 'preview' block, and give them a preview
      imageURLMatch = ANY_IMAGE_URL_REGEX.match(link[:expanded_url])
      if imageURLMatch && !link[:preview]
        link[:preview] = link[:expanded_url]
      end
    end
  end

end
