#!/usr/bin/env ruby
# encoding: UTF-8

# This is a file containing all the global but non-user-configurable data.

VERSION = "3.0.3"

FACEBOOK_PERMISSIONS = 'status_update,read_stream,publish_stream,manage_notifications,user_groups,offline_access'

TWIXT_URL = 'http://twixt.successwhale.com/index.php'
TWIXT_URL_MATCHER = 'twixt.successwhale.com'
INSTAGRAM_URL_REGEX = /http:\/\/instagram.com\/p\/(.*)\//
TWITPIC_URL_REGEX = /http:\/\/twitpic.com\/(.*)/
IMGUR_URL_REGEX = /http:\/\/imgur.com\/(.*)/
ANY_IMAGE_URL_REGEX = %r{\.(gif|jpe?g|png)$}i

UPLOAD_DIR = '/tmp'

T_CO_LENGTH = 24

NOT_AUTH_ERROR = 'User is not logged in. Log in at /v3/authenticate first, and use the returned \'token\' string as a parameter to each API call.'
