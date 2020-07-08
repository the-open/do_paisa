class WebhookPayload
  def initialize(system, transaction, processor)
    @system = system
    @transaction = transaction
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
    {
      system: 'do_paisa',
      processor: {
        name: @transaction.processor.name,
        id: @transaction.processor.id
      },
      transaction: {
        id: @transaction.id,
        amount: @transaction.amount,
        status: @transaction.status,
        recurring: @transaction.recurring?
      },
      donor: {
        id: @transaction.donor.id,
        metadata: @transaction.donor.metadata
      }
    }
  end

  def identity_payload
    payload = {
      api_token: Rails.application.secrets.identity_api_token,
      system: 'do_paisa',
      external_id: @transaction.id,
      email: @transaction.donor.metadata['email'],
      first_name: @transaction.donor.metadata['first_name'],
      last_name: @transaction.donor.metadata['last_name'],
      postcode: @transaction.donor.metadata['address_zip'],
      country: @transaction.donor.metadata['address_country'],
      created_at: @transaction.created_at,
      amount: '%.2f' % (@transaction.amount / 100.to_f).round(2),
      card_brand: 'unknown',
      source: "#{@transaction.source_external_id}|#{@transaction.source_system}",
      source_system: @transaction.source_system,
      source_external_id: @transaction.source_external_id,
      medium: @processor.name,
      status: @transaction.status
    }

    if @transaction.donor.metadata['po_guid'].present?
      source = "#{@transaction.source_external_id} - #{@transaction.donor.metadata['po_guid']}"
      payload[:source] = source
    end

    if @transaction.recurring_donor_id
      payload.merge!({
        regular_donation_system: @processor.name,
        regular_donation_external_id: @transaction.recurring_donor_id,
        regular_donation_frequency: 'Monthly',
        regular_donation_started_at: @transaction.created_at,
        regular_donation_ended_at: @transaction.recurring_donor.ended_at,
        regular_donation_source: @transaction.source_external_id
      })
    end

    payload
  end
end
