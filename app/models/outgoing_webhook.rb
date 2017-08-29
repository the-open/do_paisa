class OutgoingWebhook < Webhook
  belongs_to :processor, optional: true

  def notify(transaction)
    body = {
      processor: {
        name: transaction.processor.name,
        id: transaction.processor.id
      },
      transaction: {
        id: transaction.id,
        amount: transaction.amount,
        status: transaction.status,
        recurring: transaction.recurring?
      },
      donor: {
        id: transaction.donor.id,
        metadata: transaction.donor.metadata
      }
    }.to_json

    connection = Faraday.new(url: url)
    connection.post do |request|
      request.url url
      request.headers['Content-Type'] = 'application/json'
      request.body = body
    end
  end
end
