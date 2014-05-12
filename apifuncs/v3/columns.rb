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

      users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
      user = users.first
      status 200
      returnHash[:success] = true

      # Get the column data and put it into hashes and arrays as appropriate
      columns = user['columns'].split(';')
      returnHash[:columns] = []
      columns.each do |col|
        sources = col.split('|')
        sourceHashes = []
        fullPath = ''
        sources.each do |source|
          # Try unpacking a SuccessWhale v2 style string
          parts = source.split(':')
          if parts.length > 1
            # It's v2
            account = {:service => parts[0],
                        :uid => parts[1]}
            url = parts[2]
          else
            # It's v3
            parts = source.split('/')
            account = {:service => parts[0],
                        :uid => parts[1]}
            url = parts[2..-1].join('/')
          end
            
          # Fixes for running against a SuccessWhale v2 database.
          account = fixAccountHash(account, sw_uid)
          url = fixURL(account, url)

          # Return source hash in a standard format
          sourceHash = buildSourceHash(account, '', url)

          # Combined "source path"
          fullPath << sourceHash[:fullurl] << ':'

          sourceHashes << sourceHash
        end

        column = {:sources => sourceHashes, :fullpath => fullPath[0..-2], :title => getColumnTitle(sourceHashes)}
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
    returnHash[:trace] = e.backtrace
    puts e.backtrace
  end

  makeOutput(returnHash, params[:format], 'user')
end


# Fixes for running against a SuccessWhale v2 database. Ensures that
# the GET columns API always returns SW v3 compliant column data,
# even if v2 data is in the database.
def fixAccountHash(account, sw_uid)
  if (account[:service] == 'twitter') && !(account[:uid].is_i?)
    account[:username] = account[:uid]
    twitter_users = @db.query("SELECT * FROM twitter_users WHERE username='#{@db.escape(account[:uid])}'")
    twitter_user = twitter_users.first
    if (twitter_user)
      account.merge!(:uid => twitter_user['uid'])
    end
  end
  if (account[:service] == 'facebook') && !(account[:uid].is_i?)
    facebook_users = @db.query("SELECT * FROM facebook_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
    facebook_users.each do |facebook_user|
      facebookClient = Koala::Facebook::API.new(facebook_user['access_token'])
      name = facebookClient.get_object("me")['name']
      if name == account[:uid]
        account.merge!(:uid => facebook_user['uid'])
        account[:username] = name
        break
      end
    end
  end

  account = includeUsernames(account)
  
  return account
end

# Fixes for running against a SuccessWhale v2 database. Ensures that
# the GET columns API always returns SW v3 compliant column data,
# even if v2 data is in the database.
def fixURL(account, url)
  if url.start_with?('/')
    url = url[1..url.length-1]
  end
  if (account[:service] == 'facebook') && (url == 'notifications')
    url = 'me/notifications'
  end
  if (account[:service] == 'twitter') && (url == 'statuses/mentions')
    url = 'statuses/mentions_timeline'
  end
  return url
end
