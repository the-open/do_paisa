require 'test_helper'

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "should get process" do
    get webhook_process_url
    assert_response :success
  end

end
