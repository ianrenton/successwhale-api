#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale's API, powered by Sinatra

require 'rubygems'
require 'sinatra'
require 'mysql'
require 'digest/md5'
require 'json'
require 'builder'
require 'active_support/core_ext'
require_relative 'config'

enable :sessions

# Connect to the DB, we will need this for all our API functions
con = Mysql.new DB_HOST, DB_USER, DB_PASS, DB_NAME

# Import API function files
require_relative 'apifuncs/login'
require_relative 'apifuncs/listcolumns'


# 404
not_found do
  '<h1>SuccessWhale API</h3><p>List of valid SuccessWhale API calls:</p><ul><li>POST /v1/login[.json|.xml] - Required parameters: username, password</li><li>GET /v1/listcolumns[.json|.xml] (Requires authentication)</li></ul>'
end


# Make JSON or XML and return it
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
