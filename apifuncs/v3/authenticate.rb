#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using their SuccessWhale login


post '/v3/authenticate.?:format?' do

  returnHash = {}

  begin

    connect()

    # Check all required parameters present
    if params['username'] && params['password']

      # Get parameters
      username = params[:username]
      password = params[:password]

      # Fetch a DB row for the given username
      users = @db.query("SELECT * FROM sw_users WHERE username='#{@db.escape(username)}'")

      if users.count == 1
        # A user matched the supplied username, so let's see if the password matches

        saltedPassword = @db.escape("#{password}#{ENV['PASSWORD_SALT']}")
        md5 = Digest::MD5.hexdigest(saltedPassword)

        user = users.first
        if user['password'] == md5
          # Password matches
          status 200
          returnHash[:success] = true
          returnHash[:userid] = user['sw_uid']
          returnHash[:username] = user['username']
          returnHash[:token] = user['secret']

        else
          status 401
          returnHash[:success] = false
          returnHash[:error] = 'Password did not match'
        end

      else
        status 401
        returnHash[:success] = false
        returnHash[:error] = "Unknown username: #{username}"
      end

    else
      status 400
      returnHash[:success] = false
      returnHash[:error] = "A required parameter was missing. Required parameters: username, password"
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
