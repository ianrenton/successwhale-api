#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's display settings for the
# SW web UI.  I'm not sure if this will ever be useful to a client, but I'm
# including it for completeness anyway. There should be no comparable POST
# method, as the user should be setting this stuff up in the web UI itself.


get '/v3/displaysettings.?:format?' do

  returnHash = {}

  begin

    authResult = checkAuth(session, params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}'")
      user = users.fetch_hash
      returnHash[:success] = true

      # Get the display settings and add them to the return hash
      returnHash[:theme] = user['theme']
      returnHash[:colsperscreen] = user['colsperscreen']
      returnHash[:highlighttime] = user['highlighttime']

    else
      returnHash[:success] = false
      returnHash[:error] = NOT_AUTH_ERROR
    end

  rescue => e
    returnHash[:success] = false
    returnHash[:error] = e
  end

  makeOutput(returnHash, params[:format], 'user')
end