#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve the accounts that the user is
# currently set to post to when they type in the main post box


get '/v3/posttoaccounts.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    user = users.fetch_hash
    returnHash[:success] = true

    # Get the account data and put it into hashes and arrays as appropriate
    accounts = user['posttoservices'].split(';')
    returnHash[:posttoaccounts] = []
    accounts.each do |account|
      parts = account.split(':')
      accountHash = {:service => parts[0],
                  :user => parts[1]}
      returnHash[:posttoaccounts] << accountHash
    end

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'user')
end