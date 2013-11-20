#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to retrieve status information about the API itself.
# Currently limited to just the version string.

get '/v3/status.?:format?' do

  returnHash = {}

  begin

    status 200
    returnHash[:success] = true
    returnHash[:version] = VERSION

  rescue => e
    status 500
    returnHash[:success] = false
    returnHash[:error] = e.message
    returnHash[:errorclass] = e.class
    returnHash[:trace] = e.backtrace
  end

  makeOutput(returnHash, params[:format], 'status')
end
