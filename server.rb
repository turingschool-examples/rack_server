require 'rack'

class Server
  def call(env)
    ['200', {'Content-Type' => 'text/html'}, ["<h1>Meow You Have A barebones rack app.</h1><img src='http://i.telegraph.co.uk/multimedia/archive/02830/cat_2830677b.jpg'>"]]
  end
end

