# encoding: UTF-8
require './api'

use Rack::ShowExceptions
use Rack::Deflater

set :protection, :except => [:http_origin]

run Sinatra::Application
