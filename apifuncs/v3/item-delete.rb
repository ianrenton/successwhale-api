#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to delete an item.
# Takes the ID of an item, and the service and user ID to perform the
# deletion as.

delete '/v3/item.?:format?' do

  returnHash = {}

  begin

    authResult = checkAuth(session, params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      # Check we have been given the 'service', 'uid' and 'postid' parameters
      if params.has_key?('service') && params.has_key?('uid') && params.has_key?('postid')

        status 200
        returnHash[:success] = true

        # Do the action
        if params['service'] == 'twitter'
          twitter_users = CON.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

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
          facebook_users = CON.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.num_rows == 1
            user = facebook_users.fetch_hash

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Facebook client to post with
              facebookClient = Koala::Facebook::API.new(user['access_token'])

              # Delete the post
              facebookClient.delete_like(params['postid'])

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
    returnHash[:error] = e
  end

  makeOutput(returnHash, params[:format], 'user')
end
