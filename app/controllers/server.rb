require 'rack'

class Server
  def call(env)
    case env["PATH_INFO"]
    when "/" then index
    else
      error
    end
  end

  def index
    ['200', {'Content-Type' => 'text/html'}, [render('index.html')]]
  end

  def error
    ['404', {'Content-Type' => 'text/html'}, ["<h1>Page not found.</h1>"]]
  end

  def render(file)
    File.read("./public/#{file}")
  end
end

