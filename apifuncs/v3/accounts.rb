#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's registered social network
# accounts.
# TODO: The database currently stores Twitter tokens as a hash converted to a
# string using PHP's serialize() method. This means the Ruby API now needs
# the php-serialize gem to unserialize the data. When we next update SW's
# database schema, this ought to change.


get '/v3/accounts.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    returnHash[:success] = true
    accounts = []

    twitter_users = CON.query("SELECT * FROM twitter_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    twitter_users.each_hash do |user|
      unserializedServiceTokens = PHP.unserialize(user['access_token'])
      userHash = {:service => 'twitter',
                  :username => user['username'],
                  :userid => user['uid'],
                  :servicetokens => unserializedServiceTokens}
      accounts << userHash
    end

    facebook_users = CON.query("SELECT * FROM facebook_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    facebook_users.each_hash do |user|
      userHash = {:service => 'facebook',
                  :userid => user['uid'],
                  :servicetokens => user['access_token']}
      accounts << userHash
    end

    linkedin_users = CON.query("SELECT * FROM linkedin_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    linkedin_users.each_hash do |user|
      userHash = {:service => 'linkedin',
                  :username => user['username'],
                  :userid => user['uid'],
                  :servicetokens => user['access_token']}
      accounts << userHash
    end

    returnHash[:accounts] = accounts

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'user')
end