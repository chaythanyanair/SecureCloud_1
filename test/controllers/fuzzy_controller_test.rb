require 'test_helper'

class FuzzyControllerTest < ActionController::TestCase
  test "should get fuzzy_search" do
    get :fuzzy_search
    assert_response :success
  end

end
