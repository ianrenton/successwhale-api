#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's banned phrases list


get '/v3/bannedphrases.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    user = users.fetch_hash
    returnHash[:success] = true

    # Get the blocklist data as an array
    returnHash[:bannedphrases] = user['blocklist'].split(/\r?\n/)

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'user')
end