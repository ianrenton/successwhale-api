#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's display settings for the
# SW web UI.  I'm not sure if this will ever be useful to a client, but I'm
# including it for completeness anyway. There should be no comparable POST
# method, as the user should be setting this stuff up in the web UI itself.


get '/v3/displaysettings.?:format?' do

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

      # Get the display settings and add them to the return hash
      returnHash[:theme] = user['theme']
      returnHash[:colsperscreen] = user['colsperscreen']
      returnHash[:highlighttime] = user['highlighttime']

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
