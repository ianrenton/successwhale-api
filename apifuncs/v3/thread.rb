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

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      status 200
      returnHash[:success] = true
      items = []

      # Check we have been given the 'service', 'uid' and 'postid' parameters
      if params['service'] && params['uid'] && params['postid']

        if params[:service] == 'twitter'
          # Grab the twitter auth tokens for the account
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{@db.escape(params[:uid])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.count == 1
            user = twitter_users.first

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to fetch the items
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::REST::Client.new do |config|
                config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
                config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
                config.access_token = unserializedServiceTokens['oauth_token']
                config.access_token_secret = unserializedServiceTokens['oauth_token_secret']
              end

              # Fetch the items in the replyTo chain
              nextID = params[:postid]
              begin
                tweet = twitterClient.status(nextID)
                item = Item.new(params[:service], params[:uid], user['username'])
                item.populateFromTweet(tweet)
                # Skip first if requested, otherwise (i.e. no skipfirst or
                # this isn't the first tweet) add the tweet to the array to
                # return.
                if !(params['skipfirst'] && params[:skipfirst] == 'true' && nextID == params[:postid])
                  items << item
                end
                # If it's a retweet, get the original tweet's "in reply to" ID
                if tweet.retweet?
                  nextID = tweet.retweeted_status.attrs[:in_reply_to_status_id_str]
                else
                  nextID = tweet.attrs[:in_reply_to_status_id_str]
                end
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
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(params[:uid])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.count == 1
            user = facebook_users.first

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to fetch the item
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Fetch the item
              fbpost = facebookClient.get_object(params[:postid])

              if fbpost.nil?
                raise 'There was a problem retrieving the item from Facebook.'
              end

              item = Item.new(params[:service], params[:uid], '')
              item.populateFromFacebookPost(fbpost)

              # First item, the parent
              # Skip this if requested, otherwise add the post to the array
              # that will also contain the comments.
              if !(params['skipfirst'] && params[:skipfirst] == 'true')
                items << item
              end

              # If the first item was a notification, get the source of that
              # so we have something to pull comments from
              if item.getType == 'facebook_notification'
                if fbpost['object'].nil?
                  raise 'The application does not have permission to view the item you were notified about. You will have to use the Facebook website.'
                end
                fbpost = facebookClient.get_object(fbpost['object']['id'])
                item = Item.new(params[:service], params[:uid], '')
                item.populateFromFacebookPost(fbpost)
                items << item
              end

              # Comments
              if fbpost['comments'] && !fbpost['comments']['data'].nil?
                fbpost['comments']['data'].each do |comment|
                  item = Item.new(params[:service], params[:uid], '')
                  item.populateFromFacebookComment(comment)
                  items << item
                end
              end              

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
    returnHash[:error] = e.message
    returnHash[:errorclass] = e.class
    returnHash[:trace] = e.backtrace
    puts e.backtrace
  end

  makeOutput(returnHash, params[:format], 'thread')
end
