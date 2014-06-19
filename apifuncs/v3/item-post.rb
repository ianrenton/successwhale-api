#!/usr/bin/env ruby
# encoding: UTF-8

# SuccessWhale API function to post an item.
# Takes the text of the item, a set of accounts to post to, and optionally a media file. If no
# accounts are supplied, uses the user's defaults (TODO).
# An error will be thrown if a media file is provided but the type is not compatible with the
# services that are supposed to be posted to.
# Supports an in_reply_to_id parameter for replying to Tweets, FB/LinkedIn statuses etc.

post '/v3/item.?:format?' do

  returnHash = {}

  begin

    connect()

    authResult = checkAuth(params)

    if authResult[:authenticated]
      # A user matched the supplied sw_uid and secret, so authentication is OK
      sw_uid = authResult[:sw_uid]
      
      # Handle the uploaded media file, if it exists
      if (params['file'] && (params['file'] != ''))
        uploadedFilePath = UPLOAD_DIR + '/' + params['file'][:filename];
        File.open(uploadedFilePath, "w") do |f|
          f.write(params['file'][:tempfile].read)
        end
        uploadedFile = File.new(uploadedFilePath)
      end

      if params['text'] && !params['text'].empty?
        # User gave us a text parameter, so that's OK
        status 201
        returnHash[:success] = true

        if params['accounts']
          postToAccounts = params['accounts']
        end

        # Split the token string
        accounts = postToAccounts.split(':')
        accounts.each do |account|
          parts = account.split('/')
          service = parts[0]
          uid = parts[1]

          # Do the posting
          if service == 'twitter'
            twitter_users = @db.query("SELECT * FROM twitter_users WHERE uid='#{@db.escape(uid)}'")

            # Check we have an entry for the Twitter account being used
            if twitter_users.count == 1
              user = twitter_users.first

              # Check that the currently authenticated user owns that Twitter account
              if user['sw_uid'].to_i == sw_uid

                # Set up a Twitter client to post with
                unserializedServiceTokens = PHP.unserialize(user['access_token'])
                twitterClient = Twitter::REST::Client.new do |config|
                  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
                  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
                  config.access_token = unserializedServiceTokens['oauth_token']
                  config.access_token_secret = unserializedServiceTokens['oauth_token_secret']
                end

                # Set up options
                options = {}
                # Force t.co wrapping, so we can send tweets just over 140
                # chars that will be <=140 chars after wrapping
                options.merge!(:wrap_links => true)

                # Set in-reply-to if required
                if params['in_reply_to_id']
                  options.merge!(:in_reply_to_status_id => params['in_reply_to_id'])
                end

                # Post via Twixt if >140 chars
                if params['text'].length > 140
                  tweet = shortenForTwitter(URI::unescape(params['text']))
                else
                  tweet = URI::unescape(params['text'])
                end

                # Post, with file if necessary
                if uploadedFile
                  twitterClient.update_with_media(tweet, uploadedFile, options)
                else
                  twitterClient.update(tweet, options)
                end

              else
                status 403
                returnHash[:success] = false
                returnHash[:error] = "A post was requested via Twitter account @#{user['username']}, but the authenticated user does not have the right to use this account."
              end
            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A post was requested via Twitter user ID @#{uid}, but that account is not known to SuccessWhale."
            end


          elsif service == 'facebook'
            # Grab the facebook auth token for the account
            facebook_users = @db.query("SELECT * FROM facebook_users WHERE uid='#{@db.escape(uid)}'")

            # Check we have an entry for the Facebook account being used
            if facebook_users.count == 1
              user = facebook_users.first

              # Check that the currently authenticated user owns that Facebook account
              if user['sw_uid'].to_i == sw_uid

                # Set up a Facebook client to post with
                facebookClient = Koala::Facebook::API.new(user['access_token'])

                # Post the appropriate Facebook object depending on whether this
                # is a comment, a photo, or a normal post.
                if params['in_reply_to_id']
                  replyid = params['in_reply_to_id']
                  # This is a comment
                  
                  # First, check if we are trying to comment on a notification. This
                  # isn't possible, so we assume the user wanted to comment on the item
                  # that the notification was *about*.
                  # Clients *should* use SuccessWhale's 'replytoid' field in the 'reply'
                  # action properly so they will never try this, but some don't! ;)
                  if replyid.start_with?('notif_')
                    realPost = facebookClient.get_object(replyid)
                    if realPost['object'].nil?
                      raise 'The application does not have permission to comment on the item you were notified about. You will have to use the Facebook website.'
                    else
                      replyid = realPost['object']['id']
                    end
                  end
                  
                  # Now we definitely have the ID of a real post, try to comment on it.
                  begin
                    facebookClient.put_comment(params[:in_reply_to_id], URI.unescape(params['text']))
                  rescue Koala::Facebook::ServerError => e
                    # koala has a horrible bug where sometimes it will return "OAuth exception" when actually the comment was posted.
                    # This causes clients that auto-resend on temporary errors (like OnoSendai) to re-send forever, posting dozens
                    # of copies of a comment.
                    # Check for that condition here by fetching the comments for the item, and seeing if the last post matches
                    # what we just tried to send.
                    fbpost = facebookClient.get_object(params[:in_reply_to_id])
                    if fbpost['comments'] && !fbpost['comments']['data'].nil? && (fbpost['comments']['data'][-1]['message'] == URI.unescape(params['text']))
                      # Actually it was posted just fine
                      status 201
                      returnHash[:success] = true 
                    else
                      # Looks like there was a real error
                      throw e
                    end              
                  end
                elsif uploadedFile
                  # This is a picture
                  facebookClient.put_picture(uploadedFile.path, params['file'][:type], {:message => URI.unescape(params['text'])})  
                else
                  # This is a normal post
                  facebookClient.put_wall_post(URI.unescape(params['text']))
                end

              else
                status 403
                returnHash[:success] = false
                returnHash[:error] = "A post was requested via a Facebook account with uid #{uid}, but the authenticated user does not have the right to use this account."
              end
            else
              status 403
              returnHash[:success] = false
              returnHash[:error] = "A post was requested via a Facebook account with uid #{uid}, but that account is not known to SuccessWhale."
            end

          else
            status 400
            returnHash[:success] = false
            returnHash[:error] = "A post was requested via a service named '#{service}', but that SuccessWhale does not support that service."
          end
        end

      # Delete the temporary files if there were any.
      if (params['file'] && (params['file'] != ''))
        if File.exist?(params['file'][:tempfile].path)
          params['file'][:tempfile].close
          File.delete(params['file'][:tempfile].path)
        end
        if File.exist?(uploadedFile.path)
          uploadedFile.close
          File.delete(uploadedFile.path)
        end
      end

      else
        status 400
        returnHash[:success] = false
        returnHash[:error] = "The required parameter 'text' was not provided or was empty."
      end

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

# Pushes text (>140 characters) through the tweet shortening service,
# returning a tweet of the form "mylongtext... http://shortener/shortcode".
# This may be a little over 140 characters itself, but will be exactly 140
# characters once Twitter has passed the URL through t.co.
def shortenForTwitter(text)
  uri = URI.parse(TWIXT_URL)
  # Send raw=true to get the real Twixt URL not the is.gd version
  sendParams = {:tweet => text, :raw => true}
  uri.query = URI.encode_www_form( sendParams )
  res = Net::HTTP.get_response(uri)

  if res.code.to_i == 200
    # Figure out how much of the real text we're allowed to keep
    # to ensure the whole thing remains <140 chars
    preserveTextLength = 140 - 4 - T_CO_LENGTH
    text = "#{text.slice!(0..preserveTextLength)}... #{res.body}"
  else
    raise "Tried to post to Twitter with more than 140 characters of text, but the shortening service failed. Status #{res.code}, content: #{res.body}"
  end

  return text
end
