#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a user's registered social network
# accounts.
# TODO: The database currently stores Twitter tokens as a hash converted to a
# string using PHP's serialize() method. This means the Ruby API now needs
# the php-serialize gem to unserialize the data. When we next update SW's
# database schema, this ought to change.


get '/v3/accounts.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(session, params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      status 200
      returnHash[:success] = true
      returnHash[:accounts] = getAllAccountsForUser(sw_uid)

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