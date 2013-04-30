#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using their SuccessWhale login


post '/v3/authenticate.?:format?' do

  returnHash = {}

  begin

    connect()

    # Check all required parameters present
    if params.has_key?('username') && params.has_key?('password')

      # Get parameters
      username = params[:username]
      password = params[:password]

      # Fetch a DB row for the given username
      users = @db.query("SELECT * FROM sw_users WHERE username='#{Mysql.escape_string(username)}'")

      if users.num_rows == 1
        # A user matched the supplied username, so let's see if the password matches

        saltedPassword = Mysql.escape_string("#{password}#{ENV['PASSWORD_SALT']}")
        md5 = Digest::MD5.hexdigest(saltedPassword)

        user = users.fetch_hash
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
