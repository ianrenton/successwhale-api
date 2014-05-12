#!/usr/bin/env ruby
# encoding: UTF-8

# Sets the columns (`columns`) that the current user uses in SuccessWhale. This is an
# array with one element for each column. Each element contains a single item called
# `sources`, which is itself an array of source hashes.

# The structure of `columns` is JSON that mirrors the response from the GET columns call.
# (XML is not supported yet.) A client can send back a complete set of source definitions
# for every source in every column, but in practice the only part that is actually
# required is the `fullurl` element. 


post '/v3/columns.?:format?' do

  returnHash = {}

  begin
  
    if params['columns']

      connect()

      authResult = checkAuth(params)

      if authResult[:authenticated]
        # A user matched the supplied sw_uid and secret, so authentication is OK
        sw_uid = authResult[:sw_uid]
        
        status 200
        returnHash[:success] = true
        
        # De-JSONify the posttoaccounts hash
        columns = JSON.parse(params['columns'])
        
        # Build up a fullpath string for every column
        columnStrings = []
        columns.each do |column|
          if column['sources']
            sourceStrings = []
            column['sources'].each do |source|
              if source['fullurl']
                sourceStrings << source['fullurl']
              else
                status 400
                returnHash[:success] = false
                returnHash[:error] = 'One or more "source" elements did not contain a "fullurl" element.'
              end
            end
            columnStrings << sourceStrings.join('|')
          else
            status 400
            returnHash[:success] = false
            returnHash[:error] = 'One or more column elements did not contain a "sources" element.'
          end
        end
        fullpath = columnStrings.join(";")
        
        # Write to the DB
        @db.query("UPDATE sw_users SET `columns`='#{@db.escape(fullpath)}' WHERE `sw_uid`='#{@db.escape(sw_uid.to_s)}'")

      else
        status 401
        returnHash[:success] = false
        returnHash[:error] = NOT_AUTH_ERROR
      end
    else
      status 400
      returnHash[:success] = false
      returnHash[:error] = 'The required parameter "columns" was not provided.'
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
