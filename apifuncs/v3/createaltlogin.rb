#!/usr/bin/env ruby
# encoding: UTF-8

# Create an "alternative login" username and password. The user will then be able to use
# these credentials to log into SuccessWhale from locations where signing in with Twitter
# and Facebook are blocked.


post '/v3/createaltlogin.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]
      
      # Check all required parameters present
      if params['username'] && params['password']

        # Get parameters
        username = params[:username]
        password = params[:password]
        
        # Check username isn't already used
        users = @db.query("SELECT * FROM sw_users WHERE username='#{@db.escape(username)}'")
        user = users.first

        if (users.count == 0) || ((users.count == 1) && (user['sw_uid'] == sw_uid.to_s))
        
          # Salt and hash password
          saltedPassword = @db.escape("#{password}#{ENV['PASSWORD_SALT']}")
          md5 = Digest::MD5.hexdigest(saltedPassword)

          # Store username and password
          @db.query("UPDATE sw_users SET username='#{@db.escape(username)}', password='#{@db.escape(md5)}' WHERE sw_uid='#{@db.escape(sw_uid.to_s)}'")
          
          status 200
          returnHash[:success] = true

        else
          status 400
          returnHash[:success] = false
          returnHash[:error] = "Username #{username} is already in use. Please try another."
        end

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "A required parameter was missing. Required parameters: username, password"
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
