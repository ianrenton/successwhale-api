#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale's API, powered by Sinatra
# Written by Ian Renton
# BSD licenced (See the LICENCE file)
# https://github.com/ianrenton/successwhale-api

require 'sinatra'
require 'mysql'
require 'digest/md5'
require 'json'
require 'builder'
require 'active_support/core_ext'

# Get the configuration
if File.file?('config_local.rb')
  require_relative 'config_local'
else
  abort('API server is not configured. Edit the values in config_local_sample.rb and rename the file to config_local.rb.')
end

# Enable sessions so that we can store the user's authentication in a cookie
enable :sessions

# Connect to the DB, we will need this for all our API functions
con = Mysql.new DB_HOST, DB_USER, DB_PASS, DB_NAME

# Import API function files.  These contain all the main Sinatra processing
# code.
require_relative 'apifuncs/v3/login'
require_relative 'apifuncs/v3/listcolumns'


# 404
not_found do
  '<h1>SuccessWhale API</h3><p>List of valid SuccessWhale API calls:</p><ul><li>POST /v1/login[.json|.xml] - Required parameters: username, password</li><li>GET /v1/listcolumns[.json|.xml] (Requires authentication)</li></ul>'
end


# Utility function: Make JSON or XML and return it
def makeOutput(hash, format, xmlRoot)
  if format == 'json'
    output = hash.to_json
  elsif format == 'xml'
    output = hash.to_xml(:root => "#{xmlRoot}")
  else
    # default to json for now
    output = hash.to_json
  end
  return output
end
