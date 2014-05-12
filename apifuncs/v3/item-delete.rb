#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to delete an item.
# Takes the ID of an item, and the service and user ID to perform the
# deletion as.

delete '/v3/item.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      # Check we have been given the 'service', 'uid' and 'postid' parameters
      if params['service'] && params['uid'] && params['postid']

        status 200
        returnHash[:success] = true

        # Do the action
        if params['service'] == 'twitter'
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{@db.escape(params['uid'])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.count == 1
            user = twitter_users.first

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to post with
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::REST::Client.new do |config|
                config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
                config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
                config.access_token = unserializedServiceTokens['oauth_token']
                config.access_token_secret = unserializedServiceTokens['oauth_token_secret']
              end

              # Delete the post
              twitterClient.status_destroy(params['postid'])

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A deletion was requested via Twitter account @#{user['username']}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A deletion was requested via Twitter user ID @#{params['uid']}, but that account is not known to SuccessWhale."
          end


        elsif params['service'] == 'facebook'
          # Grab the facebook auth token for the account
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(params['uid'])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.count == 1
            user = facebook_users.first

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to post with
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Delete the post
              facebookClient.delete_object(params['postid'])

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A deletion was requested via a Facebook account with uid #{params['uid']}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A deletion was requested via a Facebook account with uid #{params['uid']}, but that account is not known to SuccessWhale."
          end

        else
          status 400
          returnHash[:success] = false
          returnHash[:error] = "A deletion was requested via a service named '#{service}', but that SuccessWhale does not support that service."
        end
        # TODO Linkedin

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

  makeOutput(returnHash, params[:format], 'user')
end
