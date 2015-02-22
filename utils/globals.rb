#!/usr/bin/env ruby
# encoding: UTF-8

# This is a file containing all the global but non-user-configurable data.

VERSION = "3.0.5"

FACEBOOK_PERMISSIONS = 'status_update,read_stream,publish_stream,manage_notifications,user_groups,user_photos,friends_photos,offline_access'

TWIXT_URL = 'http://twixt.successwhale.com/index.php'
TWIXT_URL_MATCHER = 'twixt.successwhale.com'
INSTAGRAM_URL_REGEX = /https?:\/\/instagram.com\/p\/(.+)\//
TWITPIC_URL_REGEX = /https?:\/\/twitpic.com\/(.+)/
IMGUR_URL_REGEX = /https?:\/\/(i\.)?imgur.com\/(?!gallery\/)(?!a\/_)(.+)/
ANY_IMAGE_URL_REGEX = %r{\.(gif|jpe?g|png)$}i

UPLOAD_DIR = '/tmp'

T_CO_LENGTH = 24

NOT_AUTH_ERROR = 'User is not logged in. Log in at /v3/authenticate first, and use the returned \'token\' string as a parameter to each API call.'
