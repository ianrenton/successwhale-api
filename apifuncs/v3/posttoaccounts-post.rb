#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to set the accounts that the user is expecting to post
# status updates to by default.
# The client sends `posttoaccounts` back to this function in the same manner it
# received it from the GET /posttoaccounts call. Each account has its `enabled` flag
# set as appropriate. This call notes each `enabled` account and saves the appropriate
# "posttoaccounts" string to the DB.


post '/v3/posttoaccounts.?:format?' do

  returnHash = {}

  begin
  
    if params['posttoaccounts']

      connect()

      authResult = checkAuth(params)

      if authResult[:authenticated]
        # A user matched the supplied sw_uid and secret, so authentication is OK
        sw_uid = authResult[:sw_uid]
        
        # De-JSONify the posttoaccounts hash
        accounts = JSON.parse(params['posttoaccounts'])
        
        # Build up a string for the DB field from every provided account that has
        # 'enabled=true'
        postToAccountsString = ''
        accounts.each do |account|
          if account['enabled']
            postToAccountsString += account['service'] + ':' + account['username'] + ';'
          end
        end
        
        # Write to the DB
        @db.query("UPDATE sw_users SET `posttoservices`='#{@db.escape(postToAccountsString)}' WHERE `sw_uid`='#{@db.escape(sw_uid.to_s)}'")
        
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
      returnHash[:error] = 'The required parameter "posttoaccounts" was not provided.'
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
