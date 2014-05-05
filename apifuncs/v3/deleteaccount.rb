#!/usr/bin/env ruby
# encoding: UTF-8

# Removes a third-party service (Twitter, Facebook...) account that belongs to the
# current user. Takes the name of the service (`service`) and the user ID (`uid`) on
# that service to delete.

# If this is the user's only service account and they don't have a SuccessWhale account,
# this is equivalent to deleting all information about them. If the user has other
# service accounts or has set up a SuccessWhale account, their other accounts will be
# unaffected.

# This is POST /deleteaccount not DELETE /account due to restriction of HTTP verbs that
# can be used in CORS requests by web clients.

post '/v3/deleteaccount.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      # Check we have been given the 'service' and 'uid' parameters
      if params.has_key?('service') && params.has_key?('uid')

        # Do the action
        if params['service'] == 'twitter'
          twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

          # Check we have an entry for the Twitter account being used
          if twitter_users.num_rows == 1
            user = twitter_users.fetch_hash

            # Check that the currently authenticated user owns that Twitter account
            if user['sw_uid'].to_i == sw_uid
            
              # Delete that account
              @db.query("DELETE FROM twitter_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

              status 200
              returnHash[:success] = true

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A deletion was requested of Twitter account @#{user['username']}, but that does not belong to the current user."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A deletion was requested of Twitter user ID @#{params['uid']}, but that account is not known to SuccessWhale."
          end


        elsif params['service'] == 'facebook'
          facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

          # Check we have an entry for the Facebook account being used
          if facebook_users.num_rows == 1
            user = facebook_users.fetch_hash

            # Check that the currently authenticated user owns that Facebook account
            if user['sw_uid'].to_i == sw_uid

              # Delete that account
              @db.query("DELETE FROM facebook_users WHERE uid='#{Mysql.escape_string(params['uid'])}'")

              status 200
              returnHash[:success] = true

            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A deletion was requested of the Facebook account with uid #{params['uid']}, but that does not belong to the current user."
            end
          else
            status 403
            returnHash[:success] = false
            returnHash[:error] = "A deletion was requested of the Facebook account with uid #{params['uid']}, but that account is not known to SuccessWhale."
          end

        else
          status 400
          returnHash[:success] = false
          returnHash[:error] = "A deletion was requested of a '#{service}' account, but that SuccessWhale does not support that service."
        end

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "The required parameters 'service' and 'uid' were not provided."
      end

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
