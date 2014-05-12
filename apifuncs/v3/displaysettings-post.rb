#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to save a user's display settings for the
# SW web UI. Probably not useful for other clients!


post '/v3/displaysettings.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      # Fetch existing settings
      users = @db.query("SELECT * FROM sw_users WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
      user = users.first
      
      # Update the settings
      if params['theme']
        user['theme'] = params['theme']
      end
      if params['colsperscreen']
        user['colsperscreen'] = params['colsperscreen']
      end
      if params['highlighttime']
        user['highlighttime'] = params['highlighttime']
      end
      if params['inlinemedia']
        user['inlinemedia'] = (params['inlinemedia']=='true') ? '1' : '0'
      end
      
      # Save back to the DB
      @db.query("UPDATE sw_users SET `theme`='#{@db.escape(user['theme'])}', `colsperscreen`='#{@db.escape(user['colsperscreen'])}', `highlighttime`='#{@db.escape(user['highlighttime'])}', `inlinemedia`='#{@db.escape(user['inlinemedia'])}' WHERE `sw_uid`='#{@db.escape(sw_uid.to_s)}'")

      status 200
      returnHash[:success] = true

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
