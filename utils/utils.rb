#!/usr/bin/env ruby
# encoding: UTF-8

# Util functions for the SuccessWhale API.

# Check authentication was provided by session or params, and return data
# (if authentication was successful) or an error message otherwise.
# Note that a failure here need not be terminal - other parts of the API
# may use this to specifically detect users that are *not* logged in if
# they like.
def checkAuth(session, params)

  returnHash = {}

  begin

    if session.has_key?('sw_uid') && session.has_key?('secret')
      sw_uid = session[:sw_uid].to_i
      secret = session[:secret]
    elsif params.has_key?('sw_uid') && params.has_key?('secret')
      sw_uid = params[:sw_uid].to_i
      secret = params[:secret]
    else
      sw_uid = 0
      secret = ""
    end
    if sw_uid > 0
      # Fetch a DB row for the given uid and secret
      users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}' AND secret='#{Mysql.escape_string(secret)}'")

      # If we didn't find a match, set UID to zero
      if users.num_rows == 1
        returnHash[:authenticated] = true
        returnHash[:sw_uid] = sw_uid
      else
        returnHash[:authenticated] = false
        returnHash[:error] = 'A sw_uid and secret were provided, but they did not match an entry in the database.'
      end

    else
      returnHash[:authenticated] = false
      returnHash[:error] = 'No sw_uid and secret were provided in the parameters, nor in the session cookie. The user is not logged in.'
    end

  rescue => e
    returnHash[:authenticated] = false
    returnHash[:error] = e
  end

  return returnHash
end


# Gets all social network accounts for a given user
def getAllAccountsForUser(sw_uid)
  accounts = []

  twitter_users = CON.query("SELECT * FROM twitter_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
  twitter_users.each_hash do |user|
    unserializedServiceTokens = PHP.unserialize(user['access_token'])
    userHash = {:service => 'twitter',
                :username => user['username'],
                :uid => user['uid'],
                :servicetokens => unserializedServiceTokens}
    accounts << userHash
  end

  facebook_users = CON.query("SELECT * FROM facebook_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
  facebook_users.each_hash do |user|
    userHash = {:service => 'facebook',
                :uid => user['uid'],
                :servicetokens => user['access_token']}
    accounts << userHash
  end

  linkedin_users = CON.query("SELECT * FROM linkedin_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
  linkedin_users.each_hash do |user|
    userHash = {:service => 'linkedin',
                :username => user['username'],
                :uid => user['uid'],
                :servicetokens => user['access_token']}
    accounts << userHash
  end

  return accounts
end


# Make JSON or XML from a hash and return it
def makeOutput(hash, format, xmlRoot)
  if format == 'json'
    output = hash.to_json
  elsif format == 'xml'
    output = hash.to_xml(:root => "#{xmlRoot}")
  else
    # default to json for now
    output = hash.to_json
  end
  return output
end