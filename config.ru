# encoding: UTF-8
require './api'

use Rack::ShowExceptions

disable :protection

run Sinatra::Application
