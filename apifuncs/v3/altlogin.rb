#!/usr/bin/env ruby
# encoding: UTF-8

#Gets information about the user's SuccessWhale alternative login username (if it
# exists), and for convenience a boolean flag to say whether or not it exists.


get '/v3/altlogin.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
      user = users.first

      status 200
      returnHash[:success] = true
      returnHash[:username] = user['username']
      returnHash[:hasaltlogin] = (user['username'] != '')

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
