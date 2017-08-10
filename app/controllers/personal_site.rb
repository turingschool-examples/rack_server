require 'rack'

class PersonalSite
  def self.call(env)
    case env["PATH_INFO"]
    when "/" then index
    when '/main.css' then css
    else
      error
    end
  end

  def self.index
    ['200', {'Content-Type' => 'text/html'}, [render('index.html')]]
  end

  def self.css
    ['200', {'Content-Type' => 'text/html'}, [render('main.css')]]
  end

  def self.error
    ['404', {'Content-Type' => 'text/html'}, ["<h1>Page not found.</h1>"]]
  end

  def self.render(file)
    File.read("./public/#{file}")
  end
end

