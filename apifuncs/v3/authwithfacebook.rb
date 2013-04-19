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
      me = facebookClient.get_object("me")
      fb_uid = me[:id]

      # Everything from here on is a success
      status 200
      returnHash[:success] = true
      returnHash[:me] = me
      returnHash[:fb_uid] = fb_uid

      # Check if the user is authenticated with SW by checking the 'state'
      # parameter that FB returned as if it were the token
      if params.has_key?('state')
        newParams = {:token => params[:state]}
        returnHash[:newparams] = newParams
        authResult = checkAuth(newParams)
        returnHash[:authresult] = authResult

        if authResult[:authenticated]
          # We have an authenticated SW user
          # Check to see if the token is already in the database
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE token='#{Mysql.escape_string(token)}'")
          if facebook_users.num_rows == 1
            # That Facebook account is already known to SW
            fb_account_sw_uid = facebook_users.fetch_hash['sw_uid']
            if fb_account_sw_uid == authResult[:sw_uid]
              # The Facebook account is already assigned to the current user
              returnHash.merge!(getUserBlock(authResult[:sw_uid]))
            else
              # The Facebook account belongs to a different user, so move it
              # to this one.
              userBlock = getUserBlock(authResult[:sw_uid])
              @db.query("DELETE * FROM facebook_users WHERE token='#{Mysql.escape_string(token)}'")
              @db.query("INSERT INTO facebook_users (sw_uid, uid, token) VALUES ('#{Mysql.escape_string(userBlock[:sw_uid])}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
              returnHash.merge!(userBlock)
            end
          else
            # This is an existing user activating a new FB account
            userBlock = getUserBlock(authResult[:sw_uid])
            @db.query("INSERT INTO facebook_users (sw_uid, uid, token) VALUES ('#{Mysql.escape_string(userBlock[:sw_uid])}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
            ######## TODO DEFAULT COLUMNS
            returnHash.merge!(userBlock)
          end

        else
          # This is a new user starting off by activating a FB account
          sw_uid = makeSWAccount() ### TODO
          @db.query("INSERT INTO facebook_users (sw_uid, uid, token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
          ######## TODO DEFAULT COLUMNS
          userBlock = getUserBlock(sw_uid)
          returnHash.merge!(userBlock)
        end

      else
        # This is a new user starting off by activating a FB account
        sw_uid = makeSWAccount() ### TODO
        @db.query("INSERT INTO facebook_users (sw_uid, uid, token) VALUES ('#{Mysql.escape_string(sw_uid)}', '#{Mysql.escape_string(fb_uid)}', '#{Mysql.escape_string(token)}')")
        ######## TODO DEFAULT COLUMNS
        userBlock = getUserBlock(sw_uid)
        returnHash.merge!(userBlock)
      end
    end

  rescue => e
    status 500
    returnHash[:success] = false
    returnHash[:error] = e.message
    returnHash[:errorclass] = e.class
  end

  makeOutput(returnHash, params[:format], 'authinfo')
end
