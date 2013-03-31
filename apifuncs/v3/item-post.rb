#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to post an item.
# Takes the text of the item, and a set of accounts to post to. If no
# accounts are supplied, uses the user's defaults (TODO).
# Supports an in_reply_to_id parameter for replying to Tweets, FB/LinkedIn
# statuses etc.

post '/v3/item.?:format?' do

  returnHash = {}

  begin

    authResult = checkAuth(session, params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      if params.has_key?('text')
        # User gave us a text parameter, so that's OK
        status 200
        returnHash[:success] = true

        if params.has_key?('accounts')
          postToAccounts = params['accounts']
        else
          postToAccounts = '' # TODO
        end

        # Split the token string
        accounts = postToAccounts.split(':')
        accounts.each do |account|
          parts = account.split('/')
          service = parts[0]
          uid = parts[1]

          # Do the posting
          if service == 'twitter'
            twitter_users = CON.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(uid)}'")

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

                # Set in-reply-to if required
                options = {}
                if params.has_key?('in_reply_to_id')
                  options.merge!(:in_reply_to_status_id => params['in_reply_to_id'])
                end

                # Post
                twitterClient.update(URI.unescape(params['text']), options)

              else
                status 403
                returnHash[:success] = false
                returnHash[:error] = "A post was requested via Twitter account @#{user['username']}, but the authenticated user does not have the right to use this account."
              end
            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A post was requested via Twitter user ID @#{uid}, but that account is not known to SuccessWhale."
            end


          elsif service == 'facebook'
            # Grab the facebook auth token for the account
            facebook_users = CON.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(uid)}'")

            # Check we have an entry for the Facebook account being used
            if facebook_users.num_rows == 1
              user = facebook_users.fetch_hash

              # Check that the currently authenticated user owns that Facebook account
              if user['sw_uid'].to_i == sw_uid

                # Set up a Facebook client to post with
                facebookClient = Koala::Facebook::API.new(user['access_token'])

                # Comment if that's what was requested, otherwise post to wall
                if params.has_key?('in_reply_to_id')
                  # Comment
                  facebookClient.put_comment(params[:in_reply_to_id], URI.unescape(params['text']))
                else
                  # Post
                  facebookClient.put_wall_post(URI.unescape(params['text']))
                end

              else
                status 403
                returnHash[:success] = false
                returnHash[:error] = "A post was requested via a Facebook account with uid #{uid}, but the authenticated user does not have the right to use this account."
              end
            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A post was requested via a Facebook account with uid #{uid}, but that account is not known to SuccessWhale."
            end

          else
            status 400
            returnHash[:success] = false
            returnHash[:error] = "A post was requested via a service named '#{service}', but that SuccessWhale does not support that service."
          end
          # TODO Linkedin
        end

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "The required parameter 'text' was not provided."
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
