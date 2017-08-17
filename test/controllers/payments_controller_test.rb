require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get process" do
    get payments_process_url
    assert_response :success
  end

  test "should get add_donor" do
    get payments_add_donor_url
    assert_response :success
  end

end
