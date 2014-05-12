#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve the accounts that the user is
# currently set to post to when they type in the main post box
# To reduce the number of API calls a client needs to make, this
# returns a list of all the user's accounts, with 'enabled'=>true for
# the ones that the user has set to post to.


get '/v3/posttoaccounts.?:format?' do

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

      # Get all the user's accounts, mark as disabled to start with.
      # Also remove the tokens as we don't need to return those as part of
      # this call.
      accounts = getAllAccountsForUser(sw_uid)
      accounts.each do |account|
        account[:enabled] = false
        account.remove! :servicetokens
      end

      # Get the 'post to' field and set the "enabled" value for an account if
      # it matches something in the "post to" list
      postToAccounts = user['posttoservices'].split(';')
      postToAccounts.each do |postToAccount|
        parts = postToAccount.split(':')
        accountHash = {:service => parts[0],
                    :user => parts[1]}
        accounts.each do |account|
          if (account[:service] == parts[0]) && (account[:username] == parts[1])
            account[:enabled] = true
          end
        end
      end

      returnHash[:posttoaccounts] = accounts

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
