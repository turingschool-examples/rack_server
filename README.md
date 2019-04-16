# Ruby on Light Rails

The following tutorial is intended to introduce you to many of the topics we'll be covering in Module 2. It's not expected that you fully understand each and every topic, and entirely expected that this might be your first introduction to all of them. Try to soak it in. We'll be talking more about these topics throughout the module.

Additionally, in the coming weeks, we'll be introducing you to tools that will do some of the work we're asking you to do in this tutorial. The details of how we are implementing a server will change (we will be moving you into different app and testing frameworks in just a few days), but at this point, the important thing is to understand the big picture ideas of how the web works. The **HTTP request/response cycle with status codes, headers, verbs, and bodies** will be used in any web app you build in Sinatra, Rails, Node, Django, or Pheonix. Use this as an opportunity to peak into what the browser does when it sends a **request**, and the information an app needs to prepare in its **response**.

As always, if you have any questions or notice any issues, please feel free to reach out.

## Background

### HTTP

HTTP is a protocol that we use to transfer information over the internet. There are other protocols, however, this is the protocol we will use when serving our web pages with Rack, Sinatra and Rails.

At a high level, this protocol prescribes the information and format that is necessary when sending a **request** from your browser to a server and a **response** from that server to your browser.

#### HTTP Requests

One thing to note that might not already be apparent: when you click a link in your browser you are sending a request to a server. While we don't often see it, in the background that request is sent as a string.

For example, when we enter `google.com` into our browser and hit return, it sends the following request:

```
GET / HTTP/1.1
Host: google.com
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36
Accept: */*

```

There are three parts to this request:

* Request Line: the very first line in the request above.
* Headers: key/value pairs that provide additional information to the server.
* Body (optional): not included in the request above.

The request line can be further broken down. It includes the following:

| Part of the Request | Example Above | Description                                                                                  |
|---------------------|---------------|----------------------------------------------------------------------------------------------|
| HTTP Method         |      GET      | One of a predefined set of methods that developers use to route client requests.             |
| Relative URL        |       /       | The portion of the URL after the `.com` identifying specific content a client is requesting. |
| HTTP Version        |    HTTP/1.1   | The version of the HTTP protocol this request will use.                                      |

After that first line, this particular request includes three headers: key/value pairs that provide additional information to the server.

#### HTTP Responses

The response to the request included above looks like this:

```
HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
Content-Type: text/html; charset=UTF-8
Date: Mon, 18 Sep 2017 09:41:17 GMT
Expires: Wed, 18 Oct 2017 09:41:17 GMT
Cache-Control: public, max-age=2592000
Server: gws
Content-Length: 219
X-XSS-Protection: 1; mode=block
X-Frame-Options: SAMEORIGIN

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

Similar to the HTTP request, HTTP repsonses also have three parts:

* Status Line: first line in the response.
* Headers: key/value pairs providing additional information about the response.
* Body: the portion of the response containing the information requested (frequently HTML, CSS, or JavaScript)

The status line can further be divided into three parts:

* The HTTP Version (consistent with the request)
* An HTTP [status code](https://httpstatuses.com/): if you've ever seen a 404, that's a status code meaning that the requested information was not found.
* A reason phrase corresponding to the status code providing a short description of that code (e.g. "Moved Permanently" in the example above)

The primary task of developing applications for the web is accepting HTTP requests, determining what is being requested, and preparing a response. In the tutorial below, you'll take the HTTP request and, based on its relative URL, craft an HTTP response with a status code, headers, and a body.

Read through section 3 on [this](https://www.httpwatch.com/httpgallery/introduction/) page for more detailed information about HTTP headers and status codes, which will be used in the tutorial below.

### Ruby Web Frameworks

Ruby on Rails and Sinatra are both frameworks that use the Ruby language to serve applications on the web. One of the things these two frameworks have in common is that they use [Rack](http://rack.github.io/) to interact with the web. While these are likely the two most popular Ruby web frameworks that use Rack, there are actually many more (e.g. [Padrino](http://padrinorb.com/), [Cuba](http://cuba.is/), [Hanami](http://hanamirb.org/), [Hobbit](https://github.com/patriciomacadden/hobbit), [Utopia](https://github.com/ioquatix/utopia), [Ramaze](http://ramaze.net/), [Camping](https://github.com/camping/camping), etc.).

A little bit of knowledge about the web and Ruby will get you surprisingly far in creating a Rack-based app. In order to test this theory out, let's go ahead and see if we can put together a basic Rack app, see it locally, and deploy it to the web.

## But First... Testing!

At this point, you've had an opportunity to test applications that you've built in the terminal without any concern for how someone (e.g. a client) would interact with them using a mouse. Today that changes. So, what do we want to test on a webpage? We want to make sure that when we visit a page, **we see the content we expect**, when we click on a link, **it takes us where we expect**, when we fill out a form and hit submit, **it creates a new record**, and when we delete something, **it actually deletes from our database**. Where do we get all of this? Feature testing with Capybara (remember, feature tests are more client-oriented than unit or integration tests; they ensure that our *client-facing pages* are functioning correctly).

We're going to do a little bit of testing setup before we start coding out our server. It's going to take us a while to build an operational failing test, let alone a passing one. Let's start by creating some base directories and files.

### Setting Up

In your Terminal, move to the directory where you'd like to store your application (a directory in and of itself) and enter the following:

```
$ mkdir personal_site
$ cd personal_site
$ touch Gemfile
$ touch Rakefile
$ mkdir app
$ mkdir app/controllers
$ touch app/controllers/personal_site.rb
$ mkdir test
$ touch test/test_helper.rb
$ git init
$ git status
$ git add .
$ git status
$ git commit -m "Initial commit"
$ git status
$ hub create
$ git push origin master
```

From here on out be sure to commit as you finish adding pieces of functionality. I'm not going to tell you exactly when that is in this tutorial, so use your best judgment.

### Gemfile

Add the following to your Gemfile

```ruby
source "https://rubygems.org"

gem "minitest"
gem "pry"
gem "rake"
gem "capybara"
gem "launchy"
gem "rack"
```

A few of these will likely be new to you. You'll have plenty of time to familiarize yourself, but at a high level:

* Capybara allows us to test how our apps look in a web browser.
* Launchy allows us to stop in the middle of a test to see what is currently showing on our web page (using the command `save_and_open_page`).
* Rack is the gem we're going to use to allow us to receive HTTP requests and send HTTP responses.

Be sure to run `bundle` from the command line!

### Rakefile

With that, let's set up our Rakefile to allow us to run our tests by just typing `rake` at the command line.

```ruby
require "rake"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
```

Note that we are using a `**` when we tell Rake where to look for our test files. This will allow us to nest test files into subdirectories under `test`. Rake will run them as long as they end with `_test.rb`.

### Test Helper

Add the following to your test helper.

```ruby
require 'minitest/autorun'
require 'minitest/pride'
require 'capybara/minitest'
require './app/controllers/personal_site'

Capybara.app = PersonalSite

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
end
```

That `CapybaraTestCase` is pretty interesting. Since it inherits from `Minitest::Test`, our feature tests can inherit from it, and thus will have access to both the Minitest methods that we know and love and the new Capybara methods that we'll be using to interact with our website.

In this application, the Test Helper will be the way that our tests are made aware of our application. We do this by requiring `./app/controllers/personal_site`, and then setting `Capybara.app` to our rack app name `PersonalSite` (a class which we haven't created yet) so that Capybara knows where to look when it's running our tests.

Note that I copied most of these lines almost directly from the [Capybara documentation](https://github.com/teamcapybara/capybara). In it, there is a [Setup](https://github.com/teamcapybara/capybara#setup) section that says the following:

> If the application that you are testing is a Rack app, but not Rails, set Capybara.app to your Rack app:

```
Capybara.app = MyRackApp
```

And later, there is a section called [Using Capybara with Minitest](https://github.com/teamcapybara/capybara#using-capybara-with-minitest) which includes the following passage:

> If you are not using Rails, define a base class for your Capybara tests like so:

```
require 'capybara/minitest'

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

```

> Remember to call super in any subclasses that override teardown.

I deleted the `#teardown` method in part because 1) I didn't think we would be using sessions or changing drivers in our simple app (I don't expect you to know about/worry about these things at this point), and 2) I wanted to see if I could take it out and everything would still work.

It did.

## Can We Write a Test Already?

I think we're ready! Let's try.

Let's make one more directory so that we can organize our test suite a little bit. We're totally going to write some feature tests.

```
$ mkdir test/features
$ touch test/features/user_sees_a_homepage_test.rb
```

Open that new test file in your favorite text editor and add the following.

```ruby
require './test/test_helper'

class HomepageTest < CapybaraTestCase
  def test_user_can_see_the_homepage
    visit '/'

    assert page.has_content?("Welcome!")
    assert_equal 200, page.status_code
  end
end
```

What's all this about now? What does each line do?

1) `require './test/test_helper'` We require our test helper so that we get access to minitest and all the Capybara goodness we added to it.
1) `class HomepageTest < CapybaraTestCase` We create a new class for our test (consistent with Minitest tests that we've written in the past), except now we inherit from CapybaraTestCase because we want to have access to all of those Capybara methods in our test (and because Capybara told us that's how we do it).
1) `visit '/'` We use one of the new methods that Capybara gives us `#visit` to go to the page at the root of our application (which... I know... still doesn't exist).
1) `assert page.has_content?("Welcome!"); assert_equal 200, page.status_code` We make some assertions: the first will check to see that the argument evaluates to true, and the second will check the equality of `200` and the `page.status_code`

`page` here is also new, but basically that is Capybara's way of holding the response that we get back from our server. We'll talk more about it shortly.

If we run this test (remember, we can do this using `rake`), we should get an error saying something about an `uninitialized constant PersonalSite`. Even though we created the file and told this test about that file, we haven't actually created the class. Let's do that now.

## Making Our Test Pass

Open the `app/controllers/personal_site.rb` page and add the following:

```ruby
class PersonalSite

end
```

Run our test again, and now we get an error saying something similar to the following:

```
   1) Error:
HomepageTest#test_user_can_see_the_homepage:
TypeError: The second parameter to Session::new should be a rack app if passed.
    /Users/sespinos/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/capybara-2.15.1/lib/capybara/session.rb:79:in `initialize'
    /Users/sespinos/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/capybara-2.15.1/lib/capybara.rb:304:in `new'
    /Users/sespinos/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/capybara-2.15.1/lib/capybara.rb:304:in `current_session'
    /Users/sespinos/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/capybara-2.15.1/lib/capybara/dsl.rb:45:in `page'
    /Users/sespinos/.rbenv/versions/2.4.1/lib/ruby/gems/2.4.0/gems/capybara-2.15.1/lib/capybara/dsl.rb:50:in `block (2 levels) in <module:DSL>'
    /Users/sespinos/Desktop/personal_site/test/features/user_sees_a_homepage_test.rb:5:in `test_user_can_see_the_homepage'

1 runs, 0 assertions, 0 failures, 1 errors, 0 skips
rake aborted!
Command failed with status (1)

Tasks: TOP => default => test
(See full trace by running task with --trace)
```

The main piece that I pick out of this is that something `should be a rack app if passed`. We've included `gem rack` in our Gemfile, but haven't really done anything with it at this point. Let's dig more into that now.

## Introducing Rack

### Overview

Rack allows us to write web applications that receive HTTP requests from clients (e.g. web browsers), and send HTTP responses.

Watch [this](https://www.youtube.com/watch?v=18XDokfwIDo) video.

### Getting Started with Rack

There are just a few requirements for our application to play nicely with Rack.

1) The class that holds our app must have a method `call` that takes an argument that we'll call `env`.
1) The `call` method must return an array with three components:
    1) An HTTP status code (a three digit number that tells a client if their request was successful, and if not provides some idea of why).
    1) HTTP headers (generally providing some information about the response).
    1) A message body (usally HTML, CSS, or JavaScript).

We will also need to require `rack` in our application file.

For more information on HTTP status codes, see [this](http://www.restapitutorial.com/httpstatuscodes.html) page. If you've ever seen a page that says something like `404 Page not found`, you've seen a status code! 404 is a server's way of telling you that you did something wrong. Other popular codes include `200` (everything is great! Here's your stuff!), and `503` (Server screwed something up. Not your fault.)

It's up to us if we want to make this `call` method an instance or a class method. We're going to use a class method because that's what Rails and Sinatra do.

### Updating PersonalSite

Update your `personal_site` file as follows:

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    ['200', {'Content-Type' => 'text/html'}, ['Welcome!']] # Recall, this array includes the HTTP response status code, HTTP response headers & HTTP body
  end
end
```

That should do it. Let's run our tests again, and... Passing! Great.

Let's do a little bit of exploration.

### What's Going on Here?

#### Pry into Our App

First, put a pry into the `::call` method in our PersonalSite class:

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    require 'pry'; binding.pry
    ['200', {'Content-Type' => 'text/html'}, ['Welcome!']]
  end
end
```

And run your test.

Check to see what `env` is when you hit the pry. Spoiler: it's a hash!

It looks like there are quite a few key/value pairs in that `env` hash. Some of the interesting ones include:

* `"PATH_INFO"`: storing the path that the client is trying to visit. For now it should be `/`, which matches what we put into our test.
* `"REQUEST_METHOD"`: storing the HTTP verb that is used in the request. Currently this should be a GET. We'll learn others early in the module.
* `"QUERY_STRING"`: tells us if a user sent us any additional information in the URL. Can be used to pass data from the client to our application.

That's all interesting enough. Now let's pry into the test to see what we get there.

#### Pry into Our Test

Remove the pry from our PersonalSite class and add one to our test as follows:

```ruby
require './test/test_helper'

class HomepageTest < CapybaraTestCase
  def test_user_can_see_the_homepage
    visit '/'

    require 'pry'; binding.pry
    assert page.has_content?("Welcome!")
    assert_equal 200, page.status_code
  end
end
```

Run your test again, and check to see at this point in the test what `page` is holding. You should be able to run the following commands:

```
> page
# => #<Capybara::Session>
> page.body
# => "Welcome!"
> page.status_code
# => 200
> page.response_headers
# => {"Content-Type" => "text/html", "Content-Length" => "8"}
```

So, in our app, we tried to send a response with a body, status code and headers, and it looks like that's exactly what got sent back. It seems like Rack does some work for us to calculate the number of characters in our response ("Welcome!" has 8), but other than that, this is pretty much what we told our app to do. Nice!

When we assert that the `page.has_content?("Welcome!")`, we are checking that `Welcome!` is in the body of our response. When we assert that the status code is 200, we're checking to see that's what our server sent back.

If you want a full list of methods that you can call on page, you can run `page.methods`.

Go ahead and remove the `pry` from our test suite and run it one more time to make sure we haven't broken anything.

#### Save and Open Page

One last thing before we move on: remember that `launchy` gem that I mentioned briefly earlier? It allows us to see our page in the middle of a test. Update your test to include the command `save_and_open_page` before the assertions:

```
require './test/test_helper'

class HomepageTest < CapybaraTestCase
  def test_user_can_see_the_homepage
    visit '/'

    save_and_open_page
    assert page.has_content?("Welcome!")
    assert_equal 200, page.status_code
  end
end
```

Re-run your test. Your browser of choice should open with `Welcome!` displayed. This isn't terribly helpful to us now, but it's immensely helpful when you can't quite figure out what's happening on a website. Think of it like Pry for your browser. Your test finished running in the background, so you can close this page whenever you've gotten the information you need.

One minor annoyance: take a quick look at your project directory, and you'll see that there's a new file there that looks something like this:

```
capybara-20170810075006375354925.html
```

That's the page that `save_and_open_page` saved to your drive. And now it's polluting our project directory. It's served its purpose, so go ahead and delete it, but let's make a couple of changes so that we don't have to bother with this in the future.

First, per the [Capybara docs](https://github.com/teamcapybara/capybara#debugging), we can change where these files are saved with a Capybara setting. Let's follow the pattern they've established and set that to `./tmp/capybara`. Add the following line to your `test_helper.rb` file below where you've set the Capybara app.

```
Capybara.save_path = './tmp/capybara'
```

Run your test again, and you should see the page open again, but now in your project directory there will be a new directory `tmp` with a subdirectory `capybara` holding the file that was just created. We don't want to bother with these files, and we don't want to push them to GitHub, so create a new `.gitignore` file in your project directory (if it doesn't already exist) and add the following line:

```
tmp/capybara
```

That should do it! Go ahead and remove the `save_and_open_page` line from your test so that we don't have that page popping up every time we run our tests.

## config.ru

So we kind of have a site running. We definitely have something that passes our test and we've even seen it in our browser, but only when we run our test. We haven't actually been able to just open up a web browser and see our page. We came here to make web pages! Let's make some web pages!

Well... not so fast. We have to do a little bit of setup before we can see this in our browser.

Create a `config.ru` file by running `touch config.ru`

What does this file do? It tells Rack about our application. If our `test_helper` is the entry point for our application when our test suite is trying to access it, `config.ru` is the entry point when we're trying to access our app from the web.

Add the following to your newly created `config.ru` file.

```ruby
require './app/controllers/personal_site'

run PersonalSite
```

Save that and run `rackup` from your terminal. You should see your browser spin up and print something similar to this:

```
Puma starting in single mode...
* Version 3.9.1 (ruby 2.4.1-p111), codename: Private Caller
* Min threads: 0, max threads: 16
* Environment: development
* Listening on tcp://localhost:9292
Use Ctrl-C to stop
```

You might have a different server (mine is Puma), and that might impact exactly what gets printed, but you should have something specifying a port number that may or may not be tacked onto `localhost` (in my case `localhost:9292`). In either case, open up your browser, and enter `localhost:<port-number>` (probably `localhost:9292`) into navbar. After you hit return, you should see a page that says `Welcome!`

You've got a website!

Go back to the terminal window where your server is running and check out the new information that you see. Mine shows this:

```
::1 - - [09/Aug/2017:23:34:15 -0600] "GET / HTTP/1.1" 200 - 0.0012
::1 - - [09/Aug/2017:23:34:15 -0600] "GET /favicon.ico HTTP/1.1" 200 - 0.0010
```

It looks like two requests were made, both of them GET requests. The first for `/`, and the second for `/favicon.ico`, both of which returned 200 responses. What's that favicon request? Something that browsers send to get those little icons that show up on some sites when you open tabs. We haven't set one explicitly, but it seems like maybe Rack is doing us some more favors in the background.

## Let's build it out a bit!

This is great! We have a super simple website that we're serving locally and seeing in our browser. That in and of itself is super cool. What's next?

1) Our response is currently hard-coded into our app. Let's see if we can use what we know about File IO to create some HTML pages elsewhere and serve them up as a response.
1) Right now, `Welcome!` is the response to every request made to our server, no matter the path, parameters, or anchors (read more about what makes up a url here: [https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_URL](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_URL)). Go ahead and try it. Visit `localhost:9292/blog` and see what happens. Still `Welcome!`. Let's figure out how to display different pages to our users based on the specific URI that they visit. It would also be nice to be able to link between the two of them.
1) Additionally, we'd like to be able to add some styling to our page. Let's add links to CSS in the pages we've created and be sure that we can serve that up to our users.
1) Can we deploy our site to the web so other people can see it? You bet we can.

### 1. File IO

Wouldn't it be nice to be able to send a response that was a little longer (like a full HTML page) without clogging up our PersonalSite class? Let's shut down our server (`ctrl-c`), create a `views` folder, and put some HTML there so that we can do exactly that.

```
$ mkdir app/views
$ touch app/views/index.html
```

Add the HTML below to your new `index.html` file.

```html
<html>
  <head>
    <title>Personal Site</title>
  </head>
  <body>
    <h1>Welcome!</h1>
  </body>
</html>
```

And adjust your PersonalSite class to read from this file when preparing a response body.

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    ['200', {'Content-Type' => 'text/html'}, [File.read('./app/views/index.html')]]
  end
end
```

Run your test to make sure you haven't broken anything (should be passing). Then run `rackup` and visit `localhost:9292` to see if your page still works. You should see something with just a smidge more styling since we've applied that H1 tag to our welcome.

Done! We're serving static pages from our view folder! Great!

### 2. Serving Different Pages

Now, let's adjust our `call` method to handle requests for different pages. The first thing that I want to do is generate an error if a user is visiting a page that doesn't exist. We're going to use the `PATH_INFO` stored in the `env` hash to determine where a user is trying to go.

We could do this with an if/elsif/else block, or we could stack a bunch of return statements on top of one another, but it seems like this might be a good opportunity to practice a case statement. If you prefer either of the other options, feel free to use those.

Try to see if you can write a test before you implement the code below. It should attempt to visit some page that does not exist, assert that we get a 404 status code (indicating that the client has made an error), and assert that the page has some sort of message indicating that the page doesn't exist.

Before we start, let's create an error template in `app/views/error.html`

```html
<html>
  <head>
    <title>Personal Site</title>
  </head>
  <body>
    <h1>Page not found.</h1>
  </body>
</html>
```

And update your PersonalSite class. I'm also going to extract the different arrays that we could return into their own methods to help keep that `call` method to a reasonable length.

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    case env["PATH_INFO"]
    when '/' then index
    else
      error
    end
  end

  def self.index
    ['200', {'Content-Type' => 'text/html'}, [File.read('./app/views/index.html')]]
  end

  def self.error
    ['404', {'Content-Type' => 'text/html'}, [File.read('./app/views/error.html')]]
  end
end
```

If we run our tests, then run `rackup` we should be able to see that this is all working; we're not getting an error for any page where we have explicitly defined a route in our case statement and we get a 404 for the pages we haven't defined. (Note: you must shut down & restart your server since you've edited your application routes).

Great!

Let's add one more route so that we can display an `about` page. This will produce some repetition, so I'm going to refactor to pull those response arrays into their own method.

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    case env["PATH_INFO"]
    when '/' then index
    when '/about' then about
    else
      error
    end
  end

  def self.index
    render_view('index.html')
  end

  def self.about
    render_view('about.html')
  end

  def self.error
    render_view('error.html', '404')
  end

  def self.render_view(page, code = '200')
    [code, {'Content-Type' => 'text/html'}, [File.read("./app/views/#{page}")]]
  end
end
```

And create the `about.html` file in your `app/views` directory.

```html
<html>
  <head>
    <title>Personal Site</title>
  </head>
  <body>
    <h1>About Me!</h1>
    <p>Here's some stuff to know.</p>
  </body>
</html>
```

Run `rackup` and that seems to be working!

One more thing before we move on: let's add a link to our home page to get to this About page.

Our test for this will add some new Capybara methods.

Create a new file in your `test/features` directory called `user_can_navigate_to_about_test.rb` and add the following:

```ruby
require './test/test_helper'

class LinkTest < CapybaraTestCase
  def test_user_can_see_the_homepage
    visit '/'
    click_on "About"

    assert_equal 200, page.status_code
    assert_equal '/about', current_path
    assert page.has_content?("About Me!")
  end
end
```

* `#click_on` allows us to tell Capybara to click on a link or button.
* `current_path` holds the value of the path that would show up in our browser navbar.

See if you can make this test pass by adding a link to your `index.html` file. My solution is below.

```html
<html>
  <head>
    <title>Personal Site</title>
  </head>
  <body>
    <h1>Welcome!</h1>
    <a href="/about">About Me</a>
  </body>
</html>
```

Run the test, open the site up using `rackup` and see how you've done!

### 3. Styling

This is all great, but our page is looking a little bit plain. Let's see if we can link up some basic styling. In order to do that, we're going to want to create a separate file to hold our CSS. I'm going to follow convention and create a separate directory to hold our CSS. This is also where we would put any JavaScript or image files that we might want to put into our site.

```
$ mkdir public
$ touch public/main.css
```

Inside of that new `main.css` file, add the following:

```css
body {
  background-color: blue;
}
```

This will give us a quick way to see if our styling is linked up to our page.

In our `app/views/index.html` file, add the following line inside of the `head` tags. The html `<head>` element is a container for metadata (data about data) & the The `<link>` element within it is used to link to external style sheets (read more about the `<head>` element here: https://www.w3schools.com/html/html_head.asp). These links are automatically executed as your page loads (the HTML document is downloaded first, then the browser parses the HTML in order, `head` first; the linked css sheet is downloaded and parsed before the body. Read more here: [https://stackoverflow.com/questions/1795438/load-and-execution-sequence-of-a-web-page](https://stackoverflow.com/questions/1795438/load-and-execution-sequence-of-a-web-page)).

```html
<link rel="stylesheet" href="/main.css" title="CSS" type="text/css" />
```

If we visit the page at this point, we still see a site with a white background. What gives?

We need to add the route to actually serve this static asset. In our PersonalSite class let's add a route for this new asset, and a supporting method to serve it up.

```ruby
require 'rack'

class PersonalSite
  def self.call(env)
    case env["PATH_INFO"]
    when '/' then index
    when '/about' then about
    when '/main.css' then css
    else
      error
    end
  end

  # existing index/about/error/render_view methods

  def self.css
    render_static('main.css')
  end

  def self.render_static(asset)
    [200, {'Content-Type' => 'text/html'}, [File.read("./public/#{asset}")]]
  end
end
```

Restart your server with `rackup`, visit `localhost:9292` and you should now see a page with a blue background! In order to see the same on your `about` page you'll need to add the same link tag to `about.html` as we added to `index.html`.

### 4. Deploying

We're going to use Heroku to deploy our application. In order to do that, you're going to need to sign up for a Heroku account [here](https://signup.heroku.com/), download the Command Line Interface by following the MacOS instructions [here](https://devcenter.heroku.com/articles/heroku-cli#macos), and following the [Getting Started](https://devcenter.heroku.com/articles/heroku-cli#getting-started) instructions. Be sure that you're in your site directory when you run `heroku create`

If you copy and paste the URI that is returned (the `heroku.com` link, not the `.git` link), you should see a screen welcoming you to your new Heroku app.

Great!

But that's not your application.

That's o.k. One of the things that `heroku create` did in the background was add a second git remote (you can see this by running `git remote -v`). Now you can push to that remote using `git push heroku master` (make sure you've added & committed your recent changes). When you run this command it will output a lot of information showing that your site is being uploaded and Heroku is starting it up.

Visit the site again, and you should see your website in all its blue glory!

How awesome is that!? Send it to all your friends and explain to them how cool it is.

## Checks for Understanding

1. What is HTTP?
1. What is an HTTP Method (also known as an HTTP Verb)?
1. What is an HTTP request?
1. Describe the three parts of the HTTP request line.
1. Describe the HTTP request headers.
1. Describe the HTTP request body.
1. What is an HTTP response? 
1. Describe the three parts of the HTTP status line.
1. Describe the HTTP response headers.
1. Describe the HTTP response body.
1. What is a Web Framework?
1. What is a status code?
1. What does it mean to deploy your application?

## Next Steps

Add text and styling to your welcome/about me pages and create a page to hold a blog post that you write. Feel free to change the organization of the site as you see fit (Do you want more pages? Fewer? Up to you!). I'll also leave it up to you if you'd like to maintain your test suite or ditch it (just this once!).

## Extensions

* Those static assets are a little bit of a pain. Check to see if you can create a function to check to see if a file exists in `public` and if not display your error page. You can then call that at the end of your case statement in place of `error`.
* What happens if we want to create a bunch of blog posts? Create a route in your case statement that includes a wild-card character such that if we visit `/blogs/1`, `/blogs/2`, `/blogs/3`, etc. we are directed to the appropriate blog post without having to create multiple routes.
* Use the `tilt` gem and adjust your `render_view` method to allow you to use the following template to remove some of the duplication in your views:

```html
<html>
  <head>
    <title>Personal Site</title>
    <link rel="stylesheet" href="/main.css" title="CSS" type="text/css" />
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

The `yield` in the template above will yield a block that's passed to it. It's actually part of Ruby that you might not have explored up to this point. See if you can find additional information about it online.

