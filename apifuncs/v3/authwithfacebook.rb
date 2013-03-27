#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using with Facebook.
# Comes in two GET forms - one, when no parameters are provided, which
# returns the URL to visit to authorise the app. The second form, when
# a code parameter is supplied, is used when data is being returned from
# Facebook via callback.


get '/v3/authwithfacebook.?:format?' do
  returnHash = {}

  if !params.has_key?('code')
    # No code provided, so this isn't a callback - return a URL that
    # the user can be sent to to kick off authentication.
    returnHash[:url] = FACEBOOK_OAUTH.url_for_oauth_code(:callback => request.url, :permissions => FACEBOOK_PERMISSIONS)
  else
    # A code was returned, so let's validate it and process the login
    begin
      token = FACEBOOK_OAUTH.get_access_token(params[:code], {:redirect_uri => request.url})
      returnHash[:success] = true
      returnHash[:token] = token
    rescue => e
      returnHash[:success] = false
      returnHash[:error] = e
    end
  end

  makeOutput(returnHash, params[:format], 'authinfo')
end