#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's banned phrases list


get '/v3/bannedphrases.?:format?' do

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

      # Get the blocklist data as an array
      if user['blocklist']
        blocklistArray = user['blocklist'].split(/\r?\n/)
      else
        blocklistArray = []
      end
      returnHash[:bannedphrases] = blocklistArray

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
