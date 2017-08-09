require './test/test_helper'

class IndexTest < CapybaraTestCase
  def test_user_can_see_the_index
    visit '/'

    assert page.has_content?("Welcome!")
    assert_equal 200, page.status_code
  end

  def test_user_can_see_an_error_page
    visit '/nonsense'

    assert page.has_content?("Page not found")
    assert_equal 404, page.status_code
  end
end
