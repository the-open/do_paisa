class RecurringWebhookPayload
  def initialize(system, recurring_donor, processor)
    @system = system
    @recurring_donor = recurring_donor
    @processor = processor
  end

  def get_payload
    case @system
    when 'identity'
      identity_payload
    else
      default_payload
    end
  end

  private

  def default_payload
    {}
  end

  def identity_payload
    {
      api_token: Rails.application.secrets.identity_api_token,
      cons_hash: {
        firstname: @recurring_donor.donor.metadata['first_name'],
        lastname: @recurring_donor.donor.metadata['last_name'],
        emails: [
          { email: @recurring_donor.donor.metadata['email'] }
        ],
        addresses: [
          {
            line1: @recurring_donor.donor.metadata['address_line1'],
            line2: @recurring_donor.donor.metadata['address_line2'],
            town: @recurring_donor.donor.metadata['address_city'],
            state: @recurring_donor.donor.metadata['address_state'],
            postcode: @recurring_donor.donor.metadata['address_zip'],
            country: @recurring_donor.donor.metadata['address_country']
          }
        ]
      },
      medium: @processor.name,
      external_id: @recurring_donor.id,
      started_at: @recurring_donor.created_at,
      current_amount: '%.2f' % (@recurring_donor.amount / 100.to_f).round(2)
    }
  end
end