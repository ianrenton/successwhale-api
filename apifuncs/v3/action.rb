#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to perform a simple action on an item.
# Takes the ID of an item, the service and user ID to perform the action as,
# and a verb identifying the action: 'retweet', 'unretweet', 'favorite',
# 'like' or 'unlike'.

post '/v3/action.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      # Check we have been given the 'service', 'uid', 'postid' and 'action' parameters
      if params.has_key?('service') && params.has_key?('uid') && params.has_key?('postid') && params.has_key?('action')

        status 200
        returnHash[:success] = true

        # Do the action
        if params['service'] == 'twitter'
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.num_rows == 1
            user = twitter_users.fetch_hash

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to post with
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::Client.new(
                :oauth_token => unserializedServiceTokens['oauth_token'],
                :oauth_token_secret => unserializedServiceTokens['oauth_token_secret']
              )

              # Actions
              if params['action'] == 'favorite'
                twitterClient.favorite(params['postid'])
              elsif params['action'] == 'unfavorite'
                twitterClient.unfavorite(params['postid'])
              elsif params['action'] == 'retweet'
                twitterClient.retweet(params['postid'])
              else
                status 400
                returnHash[:success] = false
                returnHash[:error] = "The action '@#{params['action']}' was requested on a tweet, but the API only supports 'favorite', 'unfavorite' and 'retweet'."
              end

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "An action was requested via Twitter account @#{user['username']}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "An action was requested via Twitter user ID @#{params['uid']}, but that account is not known to SuccessWhale."
          end


        elsif params['service'] == 'facebook'
          # Grab the facebook auth token for the account
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.num_rows == 1
            user = facebook_users.fetch_hash

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to post with
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Actions
              if params['action'] == 'like'
                facebookClient.put_like(params['postid'])
              elsif params['action'] == 'unlike'
                facebookClient.delete_like(params['postid'])
              else
                status 400
                returnHash[:success] = false
                returnHash[:error] = "The action '@#{params['action']}' was requested on a Facebook item, but the API only supports 'like'."
              end

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "An action was requested via a Facebook account with uid #{params['uid']}, but the authenticated user does not have the right to use this account."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "An action was requested via a Facebook account with uid #{params['uid']}, but that account is not known to SuccessWhale."
          end

        else
          status 400
          returnHash[:success] = false
          returnHash[:error] = "An action was requested via a service named '#{service}', but that SuccessWhale does not support that service."
        end
        # TODO Linkedin

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "The required parameters 'service', 'uid', 'postid' and 'action' were not provided."
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
