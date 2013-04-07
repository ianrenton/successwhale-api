#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale's API, powered by Sinatra
# Written by Ian Renton
# BSD licenced (See the LICENCE.md file)
# Homepage: https://github.com/ianrenton/successwhale-api

require 'rubygems'
require 'bundler/setup'
require 'unicorn'
require 'sinatra'
require 'mysql'
require 'digest/md5'
require 'json'
require 'xmlsimple'
require 'builder'
require 'active_support/core_ext'
require 'php_serialize'
require 'twitter'
require 'koala'
require 'linkedin'
require 'rack/throttle'
require_relative 'utils/globals'
require_relative 'utils/extensions'
require_relative 'utils/utils'
require_relative 'classes/item'

# Throttle clients to max. 1000 API calls per hour
use Rack::Throttle::Hourly,   :max => 1000

# Abort if environment variables not set
if !ENV.has_key?('DB_HOST')
  abort('API server is not configured. Edit the values in sample.env and rename the file to .env. If running on Heroku, push the config.')
end

# Enable sessions so that we can store the user's authentication in a cookie
enable :sessions

# Import API function files.  These contain all the main Sinatra processing
# code.
require_relative 'apifuncs/v3/authenticate-get'
require_relative 'apifuncs/v3/authenticate'
require_relative 'apifuncs/v3/authwithfacebook'
require_relative 'apifuncs/v3/accounts'
require_relative 'apifuncs/v3/columns'
require_relative 'apifuncs/v3/bannedphrases'
require_relative 'apifuncs/v3/posttoaccounts'
require_relative 'apifuncs/v3/displaysettings'
require_relative 'apifuncs/v3/feed'
require_relative 'apifuncs/v3/thread'
require_relative 'apifuncs/v3/item-post'
require_relative 'apifuncs/v3/item-delete'
require_relative 'apifuncs/v3/action'


# 404
not_found do
  status 404
  '<h1>SuccessWhale API - Invalid Request</h3><p>You have made an invalid API call. For a list of valid calls, please see the <a href="https://github.com/ianrenton/successwhale-api/blob/master/docs/index.md">API docs</a>.</p>'
end
