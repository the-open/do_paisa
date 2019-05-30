class Slack
  def post_message(message)
    return unless ENV['SLACK_URL']

    HTTPClient.new.post(ENV['SLACK_URL'], { text: message }.to_json)
  end
end
