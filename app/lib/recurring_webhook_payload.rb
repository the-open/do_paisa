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
    payload = {
      api_token: Rails.application.secrets.identity_api_token,
      cons_hash: {
        firstname: @recurring_donor.donor.metadata['first_name'],
        lastname: @recurring_donor.donor.metadata['last_name'],
        emails: [
          { email: (@recurring_donor.donor.metadata['email'] || 'no-email@leadnow.ca') }
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
      frequency: 'Monthly',
      source: @recurring_donor.donor.source_external_id,
      external_id: @recurring_donor.id,
      started_at: @recurring_donor.created_at,
      updated_at: @recurring_donor.updated_at,
      current_amount: '%.2f' % (@recurring_donor.amount / 100.to_f).round(2),
      ended_at: @recurring_donor.ended_at
    }

    if @recurring_donor.donor.metadata['po_guid'].present?
      payload.merge!({
        source: @recurring_donor.donor.metadata['po_guid']
      })
      payload[:started_at] = DateTime.parse("#{@recurring_donor.next_charge_at} 16:00:00")
    end

    ended_reason = @recurring_donor.last_fail_reason.present? ? @recurring_donor.last_fail_reason : @recurring_donor.cancelled_reason
    if @recurring_donor.ended_at.present? && ended_reason
      payload.merge!({
        ended_reason: ended_reason
      })
    end

    payload
  end
end