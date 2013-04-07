# encoding: UTF-8
require './api'

use Rack::ShowExceptions

set :protection, :except => [:http_origin]

run Sinatra::Application
