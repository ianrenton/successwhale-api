#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to set the banned phrases that the user wishes to use.
# (Setting a Banned Phrase hides all items that contain a matching phrase from the
# user's view.)


post '/v3/bannedphrases.?:format?' do

  returnHash = {}

  begin
  
    if params['bannedphrases']

      connect()

      authResult = checkAuth(params)

      if authResult[:authenticated]
        # A user matched the supplied sw_uid and secret, so authentication is OK
        sw_uid = authResult[:sw_uid]
        
        # De-JSONify the bannedphrases hash
        bannedPhrasesArray = JSON.parse(params['bannedphrases'])
        bannedPhrases = bannedPhrasesArray.join("\n")
        
        # Write to the DB
        @db.query("UPDATE sw_users SET `blocklist`='#{Mysql.escape_string(bannedPhrases)}' WHERE `sw_uid`='#{Mysql.escape_string(sw_uid.to_s)}'")
        
        status 200
        returnHash[:success] = true

      else
        status 401
        returnHash[:success] = false
        returnHash[:error] = NOT_AUTH_ERROR
      end
    else
      status 400
      returnHash[:success] = false
      returnHash[:error] = 'The required parameter "bannedphrases" was not provided.'
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
