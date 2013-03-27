#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to authenticate a user using with Facebook.
# Comes in two GET forms - one, when no parameters are provided, which
# returns the URL to visit to authorise the app. The second form, when
# a code  when data is being returned from Facebook via callback.


get '/v3/authenticatewithfacebook.?:format?' do
  redirectInfo = {}
  redirectInfo[:url] = FACEBOOK_OAUTH.url_for_oauth_code(:callback => LOCATION+'/v3/authenticatewithfacebook', :permissions => FACEBOOK_PERMISSIONS)
  makeOutput(redirectInfo, params[:format], 'redirectinfo')
end