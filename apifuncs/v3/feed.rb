#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a feed.
# This is the main API call that returns what users see as a column
# within the SuccessWhale interface.

get '/v3/feed.?:format?' do

  returnHash = {}

  sw_uid = checkAuth(session, params)

  if sw_uid > 0
    # A user matched the supplied sw_uid and secret, so authentication is OK

    returnHash[:success] = true
    items = []

    # Check we have been given the 'sources' parameter
    if params.has_key?('sources')

      # For each individual source feed that makes up this SW feed...
      sources = JSON.parse(URI.unescape(params[:sources]))
      sources.each do |source|

        if source['service'] == 'twitter'
          # Grab the twitter auth tokens for the account
          twitter_users = CON.query("SELECT * FROM twitter_users WHERE username='#{Mysql.escape_string(source['username'])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.num_rows == 1
            user = twitter_users.fetch_hash

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid

              # Set up a Twitter client to fetch the source feed
              unserializedServiceTokens = PHP.unserialize(user['access_token'])
              twitterClient = Twitter::Client.new(
                :oauth_token => unserializedServiceTokens['oauth_token'],
                :oauth_token_secret => unserializedServiceTokens['oauth_token_secret']
              )

              # Fetch the feed
              #twitterURL = "/1/#{source['url']}.json"
              # sourceFeed = twitterClient.get("/1/statuses/home_timeline.json", {}).map do |status|
              #   items << status
              # end
              sourceFeed = twitterClient.home_timeline
              sourceFeed.each do |tweet|
                items << tweet.full_text
              end

            else
              returnHash[:success] = false
              returnHash[:error] = "A feed was requested for Twitter account @#{source['username']}, but the authenticated user does not have the right to use this account."
            end
          else
            returnHash[:success] = false
            returnHash[:error] = "A feed was requested for Twitter account @#{source['username']}, but that account is not known to SuccessWhale."
          end

        end

      end

      returnHash[:items] = items

    else
      returnHash[:success] = false
      returnHash[:error] = "The required parameter 'sources' was not provided."
    end

  else
    returnHash[:success] = false
    returnHash[:error] = NOT_AUTH_ERROR
  end

  makeOutput(returnHash, params[:format], 'user')
end