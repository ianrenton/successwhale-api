#!/usr/bin/env ruby
# encoding: UTF-8

# This is a file containing all the global stuff, including blank
# strings for all the values that are supposed to be set in
# config.rb.

VERSION = "3.0.0-dev"

FACEBOOK_PERMISSIONS = 'status_update,read_stream,publish_stream,manage_notifications,offline_access'

NOT_AUTH_ERROR = 'User is not logged in. Log in at /v3/authenticate first, and use the returned \'token\' string as a parameter to each API call.'
