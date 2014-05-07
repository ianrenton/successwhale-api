#!/usr/bin/env ruby
# encoding: UTF-8

# Deletes all information SuccessWhale holds on a user &mdash; their preferences, and
# all the access tokens for their associated service accounts.

# This is the nuclear option. An account deleted in this way cannot be recovered by any
# means.

# This is POST /deletealldata not DELETE /data or similar due to restriction of HTTP 
# verbs that can be used in CORS requests by web clients.

post '/v3/deletealldata.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      @db.query("DELETE FROM twitter_users WHERE sw_uid='#{Mysql.escape_string(params['uid'])}'")
      @db.query("DELETE FROM facebook_users WHERE sw_uid='#{Mysql.escape_string(params['uid'])}'")
      @db.query("DELETE FROM sw_users WHERE sw_uid='#{Mysql.escape_string(params['uid'])}'")
      
      status 200
      returnHash[:success] = true
            
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
