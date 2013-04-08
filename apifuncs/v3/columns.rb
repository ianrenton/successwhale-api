#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve column list


get '/v3/columns.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
      user = users.fetch_hash
      status 200
      returnHash[:success] = true

      # Get the column data and put it into hashes and arrays as appropriate
      columns = user['columns'].split(';')
      returnHash[:columns] = []
      columns.each do |col|
        feeds = col.split('|')
        feedsWithHashes = []
        feedPath = ''
        feeds.each do |feed|
          parts = feed.split(':')
          feedHash = {:service => parts[0],
                      :uid => parts[1],
                      :url => parts[2]}

          # Fixes for running against a SuccessWhale v2 database.
          feedHash = fixFeedHash(feedHash, sw_uid)

          # Return usernames as well as uids for rendering purposes
          feedHash = includeUsernames(feedHash)

          # Combined "feed path"
          feedPath << "#{feedHash[:service]}/#{feedHash[:uid]}/#{feedHash[:url]}:"

          feedsWithHashes << feedHash
        end

        column = {:feeds => feedsWithHashes, :feedpath => feedPath[0..-2]}
        returnHash[:columns] << column
      end

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
  end

  makeOutput(returnHash, params[:format], 'user')
end


# Fixes for running against a SuccessWhale v2 database. Ensures that
# the GET columns API always returns SW v3 compliant column data,
# even if v2 data is in the database.
def fixFeedHash(feedHash, sw_uid)
  if feedHash[:url].start_with?('/')
    feedHash.merge!(:url => feedHash[:url][1..feedHash[:url].length-1])
  end
  if (feedHash[:service] == 'facebook') && (feedHash[:url] == 'notifications')
    feedHash.merge!(:url => 'me/notifications')
  end
  if (feedHash[:service] == 'twitter') && !(feedHash[:uid].is_i?)
    feedHash[:username] = feedHash[:uid]
    twitter_users = @db.query("SELECT * FROM twitter_users WHERE username='#{Mysql.escape_string(feedHash[:uid])}'")
    twitter_user = twitter_users.fetch_hash
    feedHash.merge!(:uid => twitter_user['uid'])
  end
  if (feedHash[:service] == 'facebook') && !(feedHash[:uid].is_i?)
    facebook_users = @db.query("SELECT * FROM facebook_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
    facebook_users.each_hash do |facebook_user|
      facebookClient = Koala::Facebook::API.new(facebook_user['access_token'])
      name = facebookClient.get_object("me")['name']
      if name == feedHash[:uid]
        feedHash.merge!(:uid => facebook_user['uid'])
        feedHash[:username] = name
        break
      end
    end
  end
  return feedHash
end
