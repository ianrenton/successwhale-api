#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a feed.
# This is the main API call that returns what users see as a column
# within the SuccessWhale interface.

get '/v3/feed.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    returnHash[:success] = true
    items = []

    # Check we have been given the 'sources' parameter
    if params.has_key?('sources')

      # Default to returning 20 items if we weren't given a number
      if params.has_key?('count')
        count = params[:count].to_i
      else
        count = 20
      end

      # Grab the sources requested, assuming the input is either JSON
      # or XML depending on the output type requested
      if params[:format] == 'xml'
        sources = XmlSimple.xml_in(URI.unescape(params[:sources]), { 'ForceArray' => false })
        sources = sources[sources.first.first]
      else
        sources = JSON.parse(URI.unescape(params[:sources]))
      end
      returnHash[:request] = sources

      # For each individual source feed that makes up this SW feed...
      sources.each do |source|

        if source['service'] == 'twitter'
          # Grab the twitter auth tokens for the account
          twitter_users = CON.query("SELECT * FROM twitter_users WHERE username='#{Mysql.escape_string(source['username'])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.num_rows == 1
            user = twitter_users.fetch_hash

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to fetch the source feed
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::Client.new(
                :oauth_token => unserializedServiceTokens['oauth_token'],
                :oauth_token_secret => unserializedServiceTokens['oauth_token_secret']
              )

              # Fetch the feed
              sourceFeed = getTwitterSourceFeedFromURL(source['url'], twitterClient, count)
              sourceFeed.each do |tweet|
                item = Item.new
                item.populateFromTweet(tweet)
                items << item
              end

            else
              returnHash[:success] = false
              returnHash[:error] = "A feed was requested for Twitter account @#{source['username']}, but the authenticated user does not have the right to use this account."
            end
          else
            returnHash[:success] = false
            returnHash[:error] = "A feed was requested for Twitter account @#{source['username']}, but that account is not known to SuccessWhale."
          end

        elsif source['service'] == 'facebook'
          # Grab the facebook auth token for the account
          facebook_users = CON.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(source['uid'])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.num_rows == 1
            user = facebook_users.fetch_hash

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to fetch the source feed
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Fetch the feed
              urlParts = source['url'].split('/')
              sourceFeed = facebookClient.get_connections(urlParts[1], urlParts[2], {'include_read'=>true, 'limit'=>count})
              sourceFeed.each do |post|
                item = Item.new
                item.populateFromFacebookPost(post)
                items << item
              end

            else
              returnHash[:success] = false
              returnHash[:error] = "A feed was requested for a Facebook account with uid #{source['uid']}, but the authenticated user does not have the right to use this account."
            end
          else
            returnHash[:success] = false
            returnHash[:error] = "A feed was requested for a Facebook account with uid #{source['uid']}, but that account is not known to SuccessWhale."
          end

        end


        # TODO Linkedin

      end

      # Remove items that match the blocklist
      swusers = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
      swuser = swusers.fetch_hash
      bannedPhrases = swuser['blocklist'].split(/\r?\n/)
      items.reject! {|i| i.matchesPhrase(bannedPhrases)}

      # Sort all items in the feed by date
      items.sort { |i1, i2| i2.getTime <=> i1.getTime }

      # Truncate after required number of items and return
      returnHash[:items] = items[0,count].map{|i| i.asHash}

    else
      returnHash[:success] = false
      returnHash[:error] = "The required parameter 'sources' was not provided."
    end

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'feed')
end


# For some reason, the Twitter gem doesn't like us performing raw API
# calls with the URLs we already know. This is due to a weird text encoding
# problem that I don't know how to fix. Until then, we have this function.
# Depending on the URL passed, it will execute one of the Twitter gem's
# higher-level functions. Maybe this is a better way of doing it anyway?
# It means if Twitter changes its API, all we have to do is update the
# Twitter gem, not SuccessWhale's code.
def getTwitterSourceFeedFromURL(url, twitterClient, count)
  sourcefeed = {}
  if url == 'statuses/home_timeline'
    sourceFeed = twitterClient.home_timeline :per_page => count
  elsif url == 'statuses/user_timeline'
    sourceFeed = twitterClient.user_timeline :per_page => count
  elsif url == 'statuses/mentions'
    sourceFeed = twitterClient.mentions_timeline :per_page => count
  elsif url == 'direct_messages'
    sourceFeed = twitterClient.direct_messages_received :per_page => count
  elsif url == 'direct_messages/sent'
    sourceFeed = twitterClient.direct_messages_sent :per_page => count
  end

  # support USERNAME/lists/LISTNAME/statuses, @USERNAME and @USERNAME/LISTNAME
  return sourceFeed
end
