class Slack
  def post_message(message)
    if ENV['SLACK_URL']
      HTTPClient.new.post(ENV['SLACK_URL'], {text: message}.to_json)
    end
  end
end