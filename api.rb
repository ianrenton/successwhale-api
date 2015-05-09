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
require 'sinatra/cross_origin'
require 'mysql2'
require 'bcrypt'
require 'json'
require 'xmlsimple'
require 'builder'
require 'active_support/core_ext/hash/conversions'
require 'php_serialize'
require 'twitter'
require 'koala'
require 'nokogiri'
require 'rack/throttle'
require 'facets/string/titlecase'
require 'htmlentities'
require 'oauth'
require 'securerandom'
require 'cgi'
require 'dotenv'
require_relative 'utils/globals'
require_relative 'utils/extensions'
require_relative 'utils/utils'
require_relative 'classes/item'

# Throttle clients to max. 100000 API calls per hour
use Rack::Throttle::Hourly,   :max => 100000

# Enable CORS for JS client access from other domains
configure do
  enable :cross_origin
end

# Abort if environment variables not set
Dotenv.load
if !ENV['DB_HOST']
  abort('API server is not configured. Edit the values in sample.env and rename the file to .env. If running on Heroku, push the config.')
end

# Import API function files.  These contain all the main Sinatra processing
# code.
require_relative 'apifuncs/v3/checkauth'
require_relative 'apifuncs/v3/authenticate'
require_relative 'apifuncs/v3/authwithtwitter'
require_relative 'apifuncs/v3/authwithfacebook'
require_relative 'apifuncs/v3/deleteaccount'
require_relative 'apifuncs/v3/altlogin'
require_relative 'apifuncs/v3/createaltlogin'
require_relative 'apifuncs/v3/deletealtlogin'
require_relative 'apifuncs/v3/deletealldata'
require_relative 'apifuncs/v3/accounts'
require_relative 'apifuncs/v3/sources'
require_relative 'apifuncs/v3/columns'
require_relative 'apifuncs/v3/columns-post'
require_relative 'apifuncs/v3/bannedphrases'
require_relative 'apifuncs/v3/bannedphrases-post'
require_relative 'apifuncs/v3/posttoaccounts'
require_relative 'apifuncs/v3/posttoaccounts-post'
require_relative 'apifuncs/v3/displaysettings'
require_relative 'apifuncs/v3/displaysettings-post'
require_relative 'apifuncs/v3/feed'
require_relative 'apifuncs/v3/thread'
require_relative 'apifuncs/v3/item-post'
require_relative 'apifuncs/v3/item-delete'
require_relative 'apifuncs/v3/action'
require_relative 'apifuncs/v3/status'

# Cert test page for the web client
get '/certtest' do
  status 200
  '<h1>HTTPS Certificate Test Successful!</h1><p>Awesome! Your browser now trusts my self-signed certificate, allowing you to use SuccessWhale over a secure HTTPS connection. You can now <a href="https://successwhale.com">return to SuccessWhale</a> and use it as normal.</p>'
end

# 404
not_found do
  status 404
  '<h1>SuccessWhale API - Invalid Request</h3><p>You have made an invalid API call. For a list of valid calls, please see the <a href="https://github.com/ianrenton/successwhale-api/blob/master/docs/index.md">API docs</a>.</p>'
end
