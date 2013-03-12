#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to log a user in


post '/v3/login.?:format?' do

  returnHash = {}

  # Check all required parameters present
  if params.has_key?('username') && params.has_key?('password')

    # Get parameters
    username = params[:username]
    password = params[:password]

    # Fetch a DB row for the given username
    users = con.query("SELECT * FROM sw_users WHERE username='#{Mysql.escape_string(username)}'")

    if users.num_rows == 1
      # A user matched the supplied username, so let's see if the password matches

      saltedPassword = Mysql.escape_string("#{password}#{PASSWORD_SALT}")
      md5 = Digest::MD5.hexdigest(saltedPassword)

      user = users.fetch_hash
      if user['password'] == md5
        # Password matches
        returnHash[:success] = true
        returnHash[:userid] = user['sw_uid']
        returnHash[:username] = user['username']
        returnHash[:secret] = user['secret']
        # Save uid and secret to session var
        session[:sw_uid] = user['sw_uid']
        session[:secret] = user['secret']

      else
        returnHash[:success] = false
        returnHash[:error] = 'Password did not match'
      end

    else
      returnHash[:success] = false
      returnHash[:error] = "Unknown username: #{username}"
    end

  else
    returnHash[:success] = false
    returnHash[:error] = "A required parameter was missing. Required parameters: username, password"
  end

  makeOutput(returnHash, params[:format], 'user')
end