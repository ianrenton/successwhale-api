#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using with Twitter.
# Comes in two GET forms - one, when `callback_url` provided, which
# returns the URL to visit to authorise the app. This will include the 
# `callback_url` within it, so that once authenticated, the user will be
# redirected back to that URL.
# This callback will be a GET containing parameters called `oauth_token`
# and `oauth_verifier` which the client must pass back to this API endpoint
# in order to finish the authentication and add the Twitter account to the
# current user's set (if `token` is provided), or create a new SW user for 
# that Twitter account (if `token` isn't provided). To do this, use the
# second form of this endpoint, where `oauth_token` and `oauth_verifier` are
# provided.

get '/v3/authwithtwitter.?:format?' do

  returnHash = {}

  begin

    connect()
    oauth = OAuth::Consumer.new(ENV['TWITTER_CONSUMER_KEY'], 
                                    ENV['TWITTER_CONSUMER_SECRET'],
                             { :site => "https://api.twitter.com" })

    if params.has_key?('callback_url')
      # callback_url provided, so this isn't itself a callback - return a URL that
      # the user can be sent to to kick off authentication, unless there
      # was an explicit auth failure. (New users and properly authenticated
      # users will see the URL, auth failures and errors will see the error)
      authResult = checkAuth(params)
      if !authResult[:explicitfailure]
        status 200
        returnHash[:success] = true
        
        request_token = oauth.get_request_token(:oauth_callback => params[:callback_url])
        
        # This kind of breaks the whole RESTful idea, but we need to store these for the
        # callback to use.
        session[:request_token] = request_token.token
        session[:request_token_secret] = request_token.secret

        returnHash[:url] = request_token.authorize_url
      else
        status 401
        returnHash[:success] = false
        returnHash[:error] = authResult[:error]
      end
    elsif params.has_key?('oauth_token') && params.has_key?('oauth_verifier')
      # An oauth block was returned, so let's validate it and get an access token
      request_token = OAuth::RequestToken.new(oauth, session[:request_token],
                                        session[:request_token_secret])
                                        
      returnHash[:debug_request_token] = session[:request_token]
      returnHash[:debug_oauth_verifier] = params[:oauth_verifier]
                                        
      access_token = request_token.get_access_token(
                 :oauth_verifier => params[:oauth_verifier])

      # Everything from here on is a success
      status 200
      returnHash[:success] = true
      
      twitterParams = access_token.params
      returnHash[:test] = access_token.params
      
      # Check if the user is authenticated with SW by checking the 'token' param
      # provided to this call
      if params.has_key?('token')
        authResult = checkAuth({'token' => params[:token]})

        if authResult[:authenticated]
          # We have an authenticated SW user
          # Check to see if the Twitter account is already in the database
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")

          if !twitter_users.nil? && twitter_users.num_rows == 1
            # That Twitter account is already known to SW
            twitter_account_sw_uid = twitter_users.fetch_hash['sw_uid'].to_i

            if twitter_account_sw_uid == authResult[:sw_uid]
              # The Twitter account is already assigned to the current user,
              # update the token and return the user info
              @db.query("UPDATE twitter_users SET access_token='#{Mysql.escape_string(PHP.serialize(twitterParams))}' WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")
              returnHash.merge!(getUserBlock(authResult[:sw_uid]))
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = false
            else
              # The Twitter account belongs to a different user, so move it
              # to this one.
              userBlock = getUserBlock(authResult[:sw_uid])
              @db.query("DELETE FROM twitter_users WHERE uid='#{Mysql.escape_string(twitterParams['user_id'].to_s)}'")
              @db.query("INSERT INTO twitter_users (sw_uid, uid, username, access_token) VALUES ('#{Mysql.escape_string(userBlock[:userid])}', '#{Mysql.escape_string(twitterParams['user_id'])}', '#{Mysql.escape_string(twitterParams['screen_name'])}', '#{Mysql.escape_string(PHP.serialize(twitterParams))}')")
              addDefaultColumns(userBlock[:userid], 'twitter', twitterParams['user_id'])
              returnHash.merge!(userBlock)
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = true
            end
          else
            # This is an existing user activating a new Twitter account
            userBlock = getUserBlock(authResult[:sw_uid])
            @db.query("INSERT INTO twitter_users (sw_uid, uid, username, access_token) VALUES ('#{Mysql.escape_string(userBlock[:userid])}', '#{Mysql.escape_string(twitterParams['user_id'])}', '#{Mysql.escape_string(twitterParams['screen_name'])}', '#{Mysql.escape_string(PHP.serialize(twitterParams))}')")
            addDefaultColumns(userBlock[:userid], 'twitter', twitterParams['user_id'])
            returnHash.merge!(userBlock)
            returnHash[:sw_account_was_new] = false
            returnHash[:service_account_was_new] = true
          end

        else
           # Check to see if the Twitter account is already in the database
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")

          if !twitter_users.nil? && twitter_users.num_rows == 1
            # That Twitter account is already known to SW
            twitter_account_sw_uid = twitter_users.fetch_hash['sw_uid'].to_i
            # Update the token if necessary
            @db.query("UPDATE twitter_users SET access_token='#{Mysql.escape_string(PHP.serialize(twitterParams))}' WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")
            
            # Log in the user
            returnHash.merge!(getUserBlock(twitter_account_sw_uid))
            returnHash[:sw_account_was_new] = false
            returnHash[:service_account_was_new] = false
            
          else
            # This is a new user starting off by activating a Twitter account
            sw_uid = makeSWAccount()
            @db.query("INSERT INTO twitter_users (sw_uid, uid, username, access_token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(twitterParams['user_id'])}', '#{Mysql.escape_string(twitterParams['screen_name'])}', '#{Mysql.escape_string(PHP.serialize(twitterParams))}')")
            addDefaultColumns(sw_uid, 'twitter', twitterParams['user_id'])
            userBlock = getUserBlock(sw_uid)
            returnHash.merge!(userBlock)
            returnHash[:sw_account_was_new] = true
            returnHash[:service_account_was_new] = true
          end

        end

      else
        # Check to see if the Twitter account is already in the database
        twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")

        if !twitter_users.nil? && twitter_users.num_rows == 1
          # That Twitter account is already known to SW
          twitter_account_sw_uid = twitter_users.fetch_hash['sw_uid'].to_i
          # Update the token if necessary
          @db.query("UPDATE twitter_users SET access_token='#{Mysql.escape_string(PHP.serialize(twitterParams))}' WHERE uid='#{Mysql.escape_string(twitterParams['user_id'])}'")
          
          # Log in the user
          returnHash.merge!(getUserBlock(twitter_account_sw_uid))
          returnHash[:sw_account_was_new] = false
          returnHash[:service_account_was_new] = false
          
        else
          # This is a new user starting off by activating a Twitter account
          sw_uid = makeSWAccount()
          @db.query("INSERT INTO twitter_users (sw_uid, uid, username, access_token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(twitterParams['user_id'])}', '#{Mysql.escape_string(twitterParams['screen_name'])}', '#{Mysql.escape_string(PHP.serialize(twitterParams))}')")
          addDefaultColumns(sw_uid, 'twitter', twitterParams['user_id'])
          userBlock = getUserBlock(sw_uid)
          returnHash.merge!(userBlock)
          returnHash[:sw_account_was_new] = true
          returnHash[:service_account_was_new] = true
        end
      end

    else
      status 400
      returnHash[:success] = false
      returnHash[:error] = "This call requires either a 'callback_url' parameter, or both 'oauth_token' and 'oauth_verifier', depending on which stage of the OAuth dance you are at. Check the docs for more info."
    end

  rescue => e
    status 500
    returnHash[:success] = false
    returnHash[:error] = e.message
    returnHash[:errorclass] = e.class
    returnHash[:trace] = e.backtrace
    puts e.backtrace
  end

  makeOutput(returnHash, params[:format], 'authinfo')
end
