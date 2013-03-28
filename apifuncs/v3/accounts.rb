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

    sw_uid = checkAuth(session, params)

    if sw_uid > 0
      # A user matched the supplied sw_uid and secret, so authentication is OK

      returnHash[:success] = true
      returnHash[:accounts] = getAllAccountsForUser(sw_uid)

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