#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to find out if a given token is valid (authenticated) or not.

get '/v3/checkauth.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)
    
    status 200
    returnHash[:success] = true
    returnHash.merge! authResult

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
