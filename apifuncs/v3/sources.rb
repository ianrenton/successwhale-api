#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve a default set of sources that
# clients can suggest, based on a user's accounts. This is so that
# clients can offer a "build column" interface by blending sources
# offered by this call. Note that the list returned by this call is not
# exhaustive. This call returns all the possible sources that have
# predictable URLs. For example, for a Twitter user it will return
# 'statuses/home_timeline', but not 
#'/user/[username-matching-regex]/statuses'. This may change in future.

get '/v3/sources.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]

      status 200
      returnHash[:success] = true
      returnHash[:sources] = makeSourcesList(getAllAccountsForUser(sw_uid))

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
