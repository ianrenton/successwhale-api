#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using with Facebook.
# Comes in two GET forms - one, when `callback_url` provided, which
# returns the URL to visit to authorise the app. This will include the 
# `callback_url` within it, so that once authenticated, the user will be
# redirected back to that URL.
# This callback will be a GET containing a parameter called `code` which
# the client must pass back to this API endpoint in order to finish the
# authentication and add the Facebook account to the current user's set
# (if `token` is provided), or create a new SW user for that Facebook
# account (if `token` isn't provided). To do this, use the
# second form of this endpoint, where `code` is provided. To verify that
# it's the same client communicating, it must provide the same value
# of `callback_url` to this call too. 


get '/v3/authwithfacebook.?:format?' do

  returnHash = {}

  begin

    connect()

    if params['callback_url']
      
      # Make a new Facebook OAuth item with the callback URL set by the client,
      # instead of the normal one generated in connect().
      @oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'], params[:callback_url])
      
      if !params['code']
        # No code provided, so this isn't a callback - return a URL that
        # the user can be sent to to kick off authentication, unless there
        # was an explicit auth failure. (New users and properly authenticated
        # users will see the URL, auth failures and errors will see the error)
        authResult = checkAuth(params)
        if !authResult[:explicitfailure]
          status 200
          returnHash[:success] = true
          returnHash[:url] = @oauth.url_for_oauth_code(:permissions => FACEBOOK_PERMISSIONS)
        else
          status 401
          returnHash[:success] = false
          returnHash[:error] = authResult[:error]
        end
      else
        # A code was returned, so let's validate it
        fbToken = @oauth.get_access_token(params[:code])
        # Get FB userid to add to DB
        facebookClient = Koala::Facebook::API.new(fbToken)
        fb_uid = facebookClient.get_object("me")['id']

        # Everything from here on is a success
        status 200
        returnHash[:success] = true

        # Check if the user is authenticated with SW by checking the 'token' param
        # provided to this call
        if params['token']
          authResult = checkAuth({'token' => params[:token]})

          if authResult[:authenticated]
            # We have an authenticated SW user
            # Check to see if the FB account is already in the database
            facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(fb_uid)}'")

            if !facebook_users.nil? && facebook_users.count == 1
              # That Facebook account is already known to SW
              fb_account_sw_uid = facebook_users.first['sw_uid'].to_i

              if fb_account_sw_uid == authResult[:sw_uid]
                # The Facebook account is already assigned to the current user,
                # update the token and return the user info
                @db.query("UPDATE facebook_users SET access_token='#{@db.escape(fbToken)}' WHERE uid='#{@db.escape(fb_uid)}'")
                returnHash.merge!(getUserBlock(authResult[:sw_uid]))
                returnHash[:sw_account_was_new] = false
                returnHash[:service_account_was_new] = false
              else
                # The Facebook account belongs to a different user, so move it
                # to this one.
                userBlock = getUserBlock(authResult[:sw_uid])
                @db.query("DELETE FROM facebook_users WHERE uid='#{@db.escape(fb_uid.to_s)}'")
                @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{@db.escape(userBlock[:userid].to_s)}', '#{@db.escape(fb_uid.to_s)}', '#{@db.escape(fbToken.to_s)}')")
                addDefaultColumns(userBlock[:userid], 'facebook', fb_uid)
                addPostToAccount(userBlock[:userid], 'facebook', fb_uid)
                returnHash.merge!(userBlock)
                returnHash[:sw_account_was_new] = false
                returnHash[:service_account_was_new] = true
              end
            else
              # This is an existing user activating a new FB account
              userBlock = getUserBlock(authResult[:sw_uid])
              @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{@db.escape(userBlock[:userid].to_s)}', '#{@db.escape(fb_uid.to_s)}', '#{@db.escape(fbToken.to_s)}')")
              addDefaultColumns(userBlock[:userid], 'facebook', fb_uid)
              addPostToAccount(userBlock[:userid], 'facebook', fb_uid)
              returnHash.merge!(userBlock)
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = true
            end

          else
            # Check to see if the FB account is already in the database
            facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(fb_uid.to_s)}'")

            if !facebook_users.nil? && facebook_users.count == 1
              # That Facebook account is already known to SW
              fb_account_sw_uid = facebook_users.first['sw_uid'].to_i
              # Update the token if necessary
              @db.query("UPDATE facebook_users SET access_token='#{@db.escape(fbToken.to_s)}' WHERE uid='#{@db.escape(fb_uid.to_s)}'")
              
              # Log in the user
              returnHash.merge!(getUserBlock(authResult[:sw_uid]))
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = false
            else
              # This is a new user starting off by activating a FB account
              sw_uid = makeSWAccount()
              @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{@db.escape(sw_uid.to_s)}', '#{@db.escape(fb_uid.to_s)}', '#{@db.escape(fbToken.to_s)}')")
              addDefaultColumns(sw_uid, 'facebook', fb_uid)
              addPostToAccount(sw_uid, 'facebook', fb_uid)
              userBlock = getUserBlock(sw_uid)
              returnHash.merge!(userBlock)
              returnHash[:sw_account_was_new] = true
              returnHash[:service_account_was_new] = true
            end
          end

        else
          # Check to see if the FB account is already in the database
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(fb_uid.to_s)}'")

          if !facebook_users.nil? && facebook_users.count == 1
            # That Facebook account is already known to SW
            fb_account_sw_uid = facebook_users.first['sw_uid'].to_i
            # Update the token if necessary
            @db.query("UPDATE facebook_users SET access_token='#{@db.escape(fbToken.to_s)}' WHERE uid='#{@db.escape(fb_uid.to_s)}'")
            
            # Log in the user
            returnHash.merge!(getUserBlock(fb_account_sw_uid))
            returnHash[:sw_account_was_new] = false
            returnHash[:service_account_was_new] = false
          else
            # This is a new user starting off by activating a FB account
            sw_uid = makeSWAccount()
            @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{@db.escape(sw_uid.to_s)}', '#{@db.escape(fb_uid.to_s)}', '#{@db.escape(fbToken.to_s)}')")
            addDefaultColumns(sw_uid, 'facebook', fb_uid)
            addPostToAccount(sw_uid, 'facebook', fb_uid)
            userBlock = getUserBlock(sw_uid)
            returnHash.merge!(userBlock)
            returnHash[:sw_account_was_new] = true
            returnHash[:service_account_was_new] = true
          end
        end
      end
    else
      status 400
      returnHash[:success] = false
      returnHash[:error] = "The required parameter 'callback_url' was missing."
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
