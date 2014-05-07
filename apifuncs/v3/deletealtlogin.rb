#!/usr/bin/env ruby
# encoding: UTF-8

# Removes a user's "alternative login" username and password. The user's account will
# continue to operate normally, including logging in using Twitter and Facebook, but
# their alternative login credentials will no longer function.


post '/v3/deletealtlogin.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      @db.query("UPDATE sw_users SET username='', password='' WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")

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
