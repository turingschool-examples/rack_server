require './server'

Rack::Handler::WEBrick.run Server.new
