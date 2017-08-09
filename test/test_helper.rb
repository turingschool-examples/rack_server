require 'minitest/autorun'
require 'minitest/pride'
require 'capybara/minitest'
require './app/controllers/server'

Capybara.app = Server.new

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
end
