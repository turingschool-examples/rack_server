require 'minitest/autorun'
require 'minitest/pride'
require 'capybara/minitest'
require './app/controllers/personal_site'

Capybara.app = PersonalSite

class CapybaraTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
end
