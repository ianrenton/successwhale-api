#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a thread.
# The results vary wildly depending on the service you are retrieving a
# thread from. If you request the thread for a tweet, it grabs that tweet
# and walks the replyTo chain until it reaches the top, returning all tweets
# newest-first. If you request the thread for a Facebook post, it returns
# that post (much as it would in the feed call) but with the comment and
# like data included.

get '/v3/thread.?:format?' do

  returnHash = {}

  begin

    authResult = checkAuth(session, params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      status 200
      returnHash[:success] = true
      items = []

      # Check we have been given the 'service', 'uid' and 'postid' parameters
      if params.has_key?('service') && params.has_key?('uid') && params.has_key?('postid')

        if params[:service] == 'twitter'
          # Grab the twitter auth tokens for the account
          twitter_users = CON.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(params[:uid])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.num_rows == 1
            user = twitter_users.fetch_hash

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to fetch the first item
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::Client.new(
                :oauth_token => unserializedServiceTokens['oauth_token'],
                :oauth_token_secret => unserializedServiceTokens['oauth_token_secret']
              )

              # Fetch the items in the replyTo chain
              nextID = params[:postid]
              begin
                returnHash[:nextID] = nextID
                tweet = twitterClient.status(nextID)
                item = Item.new(params[:service], params[:uid])
                item.populateFromTweet(tweet)
                items << item
                nextID = tweet.attrs[:in_reply_to_status_id_str]
              end until (nextID == nil || nextID == 0)

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A thread was requested for Twitter account @#{user['username']}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A thread was requested for Twitter user ID @#{params[:uid]}, but that account is not known to SuccessWhale."
          end

        elsif params[:service] == 'facebook'
          # Grab the facebook auth token for the account
          facebook_users = CON.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(params[:uid])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.num_rows == 1
            user = facebook_users.fetch_hash

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to fetch the item
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Fetch the item
              fbpost = facebookClient.get_object(params[:postid])
              item = Item.new(params[:service], params[:uid])
              item.populateFromFacebookPost(fbpost)
              item.populateFacebookCommentsLikes(fbpost)
              items << item

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A thread was requested for a Facebook account with uid #{params[:uid]}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A thread was requested for a Facebook account with uid #{params[:uid]}, but that account is not known to SuccessWhale."
          end

        else
          status 400
          returnHash[:success] = false
          returnHash[:error] = "A thread was requested for a service named '#{params[:service]}', but that SuccessWhale does not support that service."
        end

        # TODO Linkedin

        returnHash[:items] = items.map{|i| i.asHash}

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "The required parameters 'service', 'uid' and 'postid' were not provided."
      end

    else
      status 401
      returnHash[:success] = false
      returnHash[:error] = NOT_AUTH_ERROR
    end

  rescue => e
    status 500
    returnHash[:success] = false
    returnHash[:error] = e
  end

  makeOutput(returnHash, params[:format], 'thread')
end
