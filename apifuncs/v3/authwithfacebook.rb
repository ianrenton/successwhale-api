#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using with Facebook.
# Comes in two GET forms - one, when no parameters are provided, which
# returns the URL to visit to authorise the app. The second form, when
# a code parameter is supplied, is used when data is being returned from
# Facebook via callback.


get '/v3/authwithfacebook.?:format?' do

  returnHash = {}

  begin

    connect()

    if !params.has_key?('code')
      # No code provided, so this isn't a callback - return a URL that
      # the user can be sent to to kick off authentication, unless there
      # was an explicit auth failure. (New users and properly authenticated
      # users will see the URL, auth failures and errors will see the error)
      authResult = checkAuth(params)
      if !authResult[:explicitfailure]
        status 200
        returnHash[:success] = true
        returnHash[:url] = @facebookOAuth.url_for_oauth_code(:callback => "#{request.base_url}#{request.path_info}", :permissions => FACEBOOK_PERMISSIONS, :state => params[:token])
      else
        status 401
        returnHash[:success] = false
        returnHash[:error] = authResult[:error]
      end
    else
      # A code was returned, so let's validate it
      token = @facebookOAuth.get_access_token(params[:code], {:redirect_uri => "#{request.base_url}#{request.path_info}"})
      # Get FB userid to add to DB
      facebookClient = Koala::Facebook::API.new(token)
      fb_uid = facebookClient.get_object("me")['id']

      # Everything from here on is a success
      status 200
      returnHash[:success] = true

      # Check if the user is authenticated with SW by checking the 'state'
      # parameter that FB returned as if it were the token
      if params.has_key?('state')
        authResult = checkAuth({'token' => params[:state]})

        if authResult[:authenticated]
          # We have an authenticated SW user
          # Check to see if the token is already in the database
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(fb_uid)}'")

          if !facebook_users.nil? && facebook_users.num_rows == 1
            # That Facebook account is already known to SW
            fb_account_sw_uid = facebook_users.fetch_hash['sw_uid']

            if fb_account_sw_uid == authResult[:sw_uid]
              # The Facebook account is already assigned to the current user,
              # update the token and return the user info
              @db.query("UPDATE facebook_users SET access_token='#{Mysql.escape_string(token)}' WHERE uid='#{Mysql.escape_string(fb_uid)}'")
              returnHash.merge!(getUserBlock(authResult[:sw_uid]))
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = false
            else
              # The Facebook account belongs to a different user, so move it
              # to this one.
              userBlock = getUserBlock(authResult[:sw_uid])
              @db.query("DELETE FROM facebook_users WHERE uid='#{Mysql.escape_string(fb_uid.to_s)}'")
              @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{Mysql.escape_string(userBlock[:userid])}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
              addDefaultColumns(userBlock[:sw_uid], 'facebook', fb_uid)
              returnHash.merge!(userBlock)
              returnHash[:sw_account_was_new] = false
              returnHash[:service_account_was_new] = true
            end
          else
            # This is an existing user activating a new FB account
            userBlock = getUserBlock(authResult[:sw_uid])
            a = "('#{Mysql.escape_string(userBlock[:userid])}')"
            a = "('#{Mysql.escape_string(fb_uid)}')"
            a = "('#{Mysql.escape_string(token)}')"
            @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{Mysql.escape_string(userBlock[:userid])}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
            addDefaultColumns(userBlock[:sw_uid], 'facebook', fb_uid)
            returnHash.merge!(userBlock)
            returnHash[:sw_account_was_new] = false
            returnHash[:service_account_was_new] = true
          end

        else
          # This is a new user starting off by activating a FB account
          sw_uid = makeSWAccount()
          @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
          addDefaultColumns(sw_uid, 'facebook', fb_uid)
          userBlock = getUserBlock(sw_uid)
          returnHash.merge!(userBlock)
          returnHash[:sw_account_was_new] = true
          returnHash[:service_account_was_new] = true
        end

      else
        # This is a new user starting off by activating a FB account
        sw_uid = makeSWAccount()
        @db.query("INSERT INTO facebook_users (sw_uid, uid, access_token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
        addDefaultColumns(sw_uid, 'facebook', fb_uid)
        userBlock = getUserBlock(sw_uid)
        returnHash.merge!(userBlock)
        returnHash[:sw_account_was_new] = true
        returnHash[:service_account_was_new] = true
      end
    end

  rescue => e
    status 500
    returnHash[:success] = false
    returnHash[:error] = e.message
    returnHash[:errorclass] = e.class
    returnHash[:trace] = e.backtrace
  end

  makeOutput(returnHash, params[:format], 'authinfo')
end
