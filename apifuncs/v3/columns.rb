#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve column list


get '/v3/columns.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    user = users.fetch_hash
    returnHash[:success] = true

    # Get the column data and put it into hashes and arrays as appropriate
    columns = user['columns'].split(';')
    returnHash[:columns] = []
    columns.each do |col|
      feeds = col.split('|')
      feedsWithHashes = []
      feeds.each do |feed|
        parts = feed.split(':')
        feedHash = {:service => parts[0],
                    :username => parts[1],
                    :url => parts[2]}
        feedsWithHashes << feedHash
      end
      returnHash[:columns] << feedsWithHashes
    end

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'user')
end