#!/usr/bin/env ruby
# encoding: UTF-8

# Util functions for the SuccessWhale API.

# Check authentication was provided by session or params, if so return sw_uid
# otherwise return 0.
def checkAuth(session, params)

  if session.has_key?('sw_uid') && session.has_key?('secret')
    sw_uid = session[:sw_uid]
    secret = session[:secret]
  elsif params.has_key?('sw_uid') && params.has_key?('secret')
    sw_uid = params[:sw_uid]
    secret = params[:secret]
  else
    sw_uid = 0
    secret = ""
  end

  # Fetch a DB row for the given uid and secret
  users = CON.query("SELECT * FROM sw_users WHERE sw_uid='#{Mysql.escape_string(sw_uid.to_s)}' AND secret='#{Mysql.escape_string(secret)}'")

  # If we didn't find a match, set UID to zero
  if users.num_rows != 1
    sw_uid = 0
  end

  return sw_uid.to_i
end


# Make JSON or XML from a hash and return it
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

# Check if a string really contains an integer
class String
  def is_i?
    !!(self =~ /^[-+]?[0-9]+$/)
  end
end