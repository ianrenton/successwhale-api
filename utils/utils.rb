#!/usr/bin/env ruby
# encoding: UTF-8

# Util functions for the SuccessWhale API.

# Connect to database and all services. Required for every API call.
def connect()

  # Connect to the DB, we will need this for all our API functions
  @db = Mysql2::Client.new(:host => ENV['DB_HOST'], :username => ENV['DB_USER'], :password => ENV['DB_PASS'], :database => ENV['DB_NAME'])
  
  # Twitter connection is handled on-demand, there is no global Twitter object
  # supported by the gem anymore.

  # Configure a Facebook object
  Koala.config.api_version = "v2.2"
  @facebookOAuth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_SECRET'])
end

# Check authentication was provided by a token parameter, and return data
# (if authentication was successful) or an error message otherwise.
# Note that a failure here need not be terminal - other parts of the API
# may use this to specifically detect users that are *not* logged in if
# they like.
def checkAuth(params)

  returnHash = {}

  begin

    if params['token']
      # Fetch a DB row for the given secret
      users = @db.query("SELECT * FROM sw_users WHERE secret='#{@db.escape(params['token'])}'")

      # If we found a match...
      if users.count == 1
        user = users.first
        
        # Check token expiry
        tokenExpires = user['tokencreated'] + 1.month
        if (Time.now < tokenExpires)
          # Token is OK
          returnHash[:authenticated] = true
          returnHash[:tokenexpired] = false
          returnHash[:explicitfailure] = false # Not an explicit failure because it was a success!
          returnHash[:sw_uid] = user['sw_uid'].to_i
        else
          # Token expired, make a new one for next time
          @db.query("UPDATE sw_users SET `secret`='#{@db.escape(createToken())}', `tokencreated`=NOW() WHERE `sw_uid`='#{user['sw_uid']}'")
          returnHash[:authenticated] = false
          returnHash[:tokenexpired] = true
          returnHash[:explicitfailure] = false
          returnHash[:error] = 'A token was provided, and it matched an expired token. The user must log in again to get a new token.'
        end
      else
        returnHash[:authenticated] = false
        returnHash[:tokenexpired] = false
        returnHash[:explicitfailure] = true # Explicit failure: token was provided but it was wrong.
        returnHash[:error] = 'A token was provided, but it did not match an entry in the database.'
      end

    else
      returnHash[:authenticated] = false
      returnHash[:tokenexpired] = false
      returnHash[:explicitfailure] = false # Not an explicit failure, could just be a new / not logged-in user
      returnHash[:error] = 'No token was provided in the parameters. The user is new or not logged in.'
    end

  rescue => e
    returnHash[:authenticated] = false
    returnHash[:tokenexpired] = false
    returnHash[:explicitfailure] = true # Explicit failure because a proper error occurred.
    returnHash[:error] = e
  end

  return returnHash
end


# Gets all social network accounts for a given user
def getAllAccountsForUser(sw_uid)
  accounts = []

  twitter_users = @db.query("SELECT * FROM twitter_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
  twitter_users.each do |user|
    unserializedServiceTokens = PHP.unserialize(user['access_token'])
    userHash = {:service => 'twitter',
                :username => user['username'],
                :uid => user['uid'],
                :servicetokens => unserializedServiceTokens}
    accounts << userHash
  end

  facebook_users = @db.query("SELECT * FROM facebook_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
  facebook_users.each do |user|
    userHash = {:service => 'facebook',
                :uid => user['uid'],
                :servicetokens => user['access_token']}

    # Add the Facebook username. This is a bit of a hack because the SWv2
    # database doesn't store usernames for Facebook accounts. TODO fix
    # when migrating database.
    userHash = includeUsernames(userHash)

    accounts << userHash
  end

  return accounts
end

# Returns a user data block for the given sw_uid
def getUserBlock(sw_uid)
  returnHash = {}

  users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
  if users.count == 1
    user = users.first
    returnHash[:success] = true
    returnHash[:userid] = user['sw_uid']
    returnHash[:username] = user['username']
    returnHash[:token] = user['secret']
  else
    returnHash[:success] = false
    returnHash[:error] = 'Tried to look up a SuccessWhale user with an invalid UID.'
  end

  return returnHash
end


# Make JSON or XML from a hash and return it.
# For convenience, close db connection at this point too.
def makeOutput(hash, format, xmlRoot)
  if format == 'json'
    content_type 'application/json'
    output = hash.to_json
  elsif format == 'xml'
    content_type 'text/xml'
    output = hash.to_xml(:root => "#{xmlRoot}")
  else
    # default to json for now
    content_type 'application/json'
    output = hash.to_json
  end
  
  # close DB connection
  if @db
    @db.close
  end
  
  return output
end


# Includes the usernames of the accounts as well as just the uids
def includeUsernames(accountHash)
  # Check if we already have a username, if we're supporting a SWv2 database
  # we probably do already
  if !accountHash[:username]
    if accountHash[:service] == 'twitter'
      twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{@db.escape(accountHash[:uid])}'")
      twitter_user = twitter_users.first
      if twitter_user
        accountHash.merge!(:username => twitter_user['username'])
      end
    end
    if accountHash[:service] == 'facebook'
      facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(accountHash[:uid])}'")
      facebook_user = facebook_users.first
      if facebook_user && facebook_user['username']
        accountHash.merge!(:username => facebook_user['username'])
      elsif facebook_user && facebook_user['access_token']
        begin
          # If we're supporting an SWv2 database, we can't get the Facebook
          # username from the table, so make a call to Facebook to get it.
          facebookClient = Koala::Facebook::API.new(facebook_user['access_token'])
          name = facebookClient.get_object("me")['name']
          accountHash.merge!(:username => name)
        rescue => e
          accountHash.merge!(:username => 'Unknown')
        end
      else
        accountHash.merge!(:username => 'Unknown')
      end
    end
  end
  return accountHash
end

# Add a new SW user to the database with default settings, and returns
# the sw_uid.
def makeSWAccount()
  token = createToken()
  result = @db.query("INSERT INTO sw_users (secret) VALUES ('#{@db.escape(token)}')")
  return @db.last_id
end

# Creates a random hex token string
def createToken()
  o =  [('0'..'9'),('a'..'f')].map{|i| i.to_a}.flatten
  string  =  (0...50).map{ o[rand(o.length)] }.join
  return string
end

# Adds the default columns for a service to a user's list
def addDefaultColumns(sw_uid, service, service_id)
  users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
  user = users.first
  currentCols = user['columns']

  if !currentCols
    currentCols = ''
  end
  if !currentCols.blank?
    currentCols << ';'
  end

  if service == 'twitter'
    currentCols << "#{service}:#{service_id}:statuses/home_timeline;"
    currentCols << "#{service}:#{service_id}:statuses/mentions_timeline;"
    currentCols << "#{service}:#{service_id}:direct_messages"
  elsif service == 'facebook'
    currentCols << "#{service}:#{service_id}:/me/home;"
    currentCols << "#{service}:#{service_id}:/me/feed;"
    currentCols << "#{service}:#{service_id}:notifications"
  end

  @db.query("UPDATE sw_users SET columns='#{@db.escape(currentCols)}' WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
end

# Adds an account to a user's "post to accounts" list
def addPostToAccount(sw_uid, service, username)
  users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
  user = users.first
  currentPTS = user['posttoservices']

  if !currentPTS
    currentPTS = ''
  end
  if !currentPTS.blank?
    currentPTS << ';'
  end
  
  currentPTS << "#{service}:#{username};"

  @db.query("UPDATE sw_users SET posttoservices='#{@db.escape(currentPTS)}' WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
end

# Makes a default list of sources for the given accounts. This is not the complete set of
# sources that can be used - for example, a Twitter account can have a source that is the
# feed of any other Twitter user, which we can't predict in advance. We catch most common
# cases though!
# This is for clients using the GET /sources call to help their users build columns.
def makeSourcesList(accounts)
  sources = []

  accounts.each do |account|
    if account[:service] == 'twitter'
      sources << buildSourceHash(account, 'Home Timeline', 'statuses/home_timeline')
      sources << buildSourceHash(account, 'Own Tweets', 'statuses/user_timeline')
      sources << buildSourceHash(account, 'Mentions', 'statuses/mentions_timeline')
      sources << buildSourceHash(account, 'Direct Messages', 'direct_messages')
      sources << buildSourceHash(account, 'Sent Messages', 'direct_messages/sent')
      # Now we have to auth with Twitter to get the lists
      twitterClient = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token = account[:servicetokens]['oauth_token']
        config.access_token_secret = account[:servicetokens]['oauth_token_secret']
      end
      begin
        lists = twitterClient.lists()
        lists.each do |list|
          sources << buildSourceHash(account, "#{list[:name].gsub(/[\-_]/,' ').titlecase} list", "lists/#{list[:slug]}/statuses")
        end
      rescue
      end
                
    elsif account[:service] == 'facebook'
      sources << buildSourceHash(account, 'Home Feed', 'me/home')
      sources << buildSourceHash(account, 'Wall', 'me/feed')
      sources << buildSourceHash(account, 'Events', 'me/events')
      sources << buildSourceHash(account, 'Notifications', 'me/notifications')
    end
  end

  return sources
end

# Utility method for makeSourcesList to build a hash describing a single source
def buildSourceHash(account, shortname, url)
  source = {}
  source.merge!(:service => account[:service])
  source.merge!(:username => account[:username])
  source.merge!(:uid => account[:uid])
  source.merge!(:shorturl => url)
  source.merge!(:fullurl => "#{account[:service]}/#{account[:uid]}/#{url}")

  # Only add name parameters if a name was provided
  if !shortname.nil? && !shortname.empty?
    source.merge!(:shortname => shortname)
    fullname = "#{account[:username]}'s #{shortname}"
    # Add '@' to usernames for twitter accounts
    if account[:service] == 'twitter'
      fullname = "@#{fullname}"
    end
    source.merge!(:fullname => fullname)
  else
    # Try to get a full name out of getColumnTitle
    bestGuessName = getColumnTitle([source])
    source.merge!(:shortname => bestGuessName)
    source.merge!(:fullname => bestGuessName)
  end
  
  return source
end

# Generates a title for a column based on the sources it uses
# TODO: base this on a lookup of the output of makeSourcesList().
def getColumnTitle(sources)

  # Can't deal with combined feeds very well yet, just throw a generic
  # title unless it's one that we vaguely understand
  if sources.length > 1
    # Mentions & Notifications Sources
    if sources.all? {|source| 
      ((source[:service] == 'twitter' && source[:shorturl] == 'statuses/mentions_timeline') ||
       (source[:service] == 'facebook' && source[:shorturl] == 'me/notifications')) }
      return 'Mentions & Notifications'

    else
      return 'Combined Feed'
    end
  end

  # Only one feed, good
  source = sources[0]

  # Try Twitter first.
  if source[:service] == 'twitter'
    # Regex matchers for Twitter feeds that have their own title style
    # Handle these first
    listMatch1 = /([A-Za-z0-9\-_]*)\/lists\/([A-Za-z0-9\-_]*)\/statuses/.match(source[:shorturl])
    listMatch2 = /@([A-Za-z0-9\-_]*)\/([A-Za-z0-9\-_]*)/.match(source[:shorturl])
    listMatch3 = /lists\/([A-Za-z0-9\-_]*)\/statuses/.match(source[:shorturl])
    userMatch1 = /user\/([A-Za-z0-9\-_]*)\/statuses/.match(source[:shorturl])
    userMatch2 = /@([A-Za-z0-9\-_]*)/.match(source[:shorturl])

    if listMatch1
      return "@#{listMatch1[1]}'s #{listMatch1[2].gsub(/[\-_]/,' ').titlecase} list"
    elsif listMatch2
      return "@#{listMatch2[1]}'s #{listMatch2[2].gsub(/[\-_]/,' ').titlecase} list"
    elsif listMatch3
      return "#{listMatch3[1].gsub(/[\-_]/,' ').titlecase} list"
    elsif userMatch1
      return "@#{userMatch1[1]}"
    elsif userMatch2
      return "@#{userMatch2[1]}"
    else
      # Not a list or a user, so treat this as the requesting user's feed
      title = "@#{source[:username]}'s "
      if source[:shorturl] == 'statuses/home_timeline'
        title << 'Home Timeline'
      elsif source[:shorturl] == 'statuses/user_timeline'
        title << 'Timeline'
      elsif source[:shorturl] == 'statuses/mentions_timeline'
        title << 'Mentions'
      elsif source[:shorturl] == 'direct_messages'
        title << 'Direct Messages'
      elsif source[:shorturl] == 'direct_messages/sent'
        title << 'Sent Messages'
      else
        title = 'Unknown Feed'
      end
      return title
    end
  elsif source[:service] == 'facebook'
    title = "#{source[:username]}'s "
    if source[:shorturl] == 'me/home'
      title << 'Home Timeline'
    elsif source[:shorturl] == 'me/feed'
      title << 'Wall'
    elsif source[:shorturl] == 'me/notifications'
      title << 'Notifications'
    elsif source[:shorturl] == 'me/events'
      title << 'Events'
    else
      title = 'Unknown Feed'
    end
  else
    return 'Unknown Feed'
  end
end
