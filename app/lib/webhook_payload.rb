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
      amount: (@transaction.amount.to_f).round(2),
      card_brand: 'unknown',
      source: "#{@transaction.source_external_id}|#{@transaction.source_system}",
      source_system: @transaction.source_system,
      source_external_id: @transaction.source_external_id,
      medium: @processor.name
    }

    if @transaction.recurring_donor.present?
      payload.merge!({ 
        regular_donation_system: 'do_paisa',
        regular_donation_external_id: @transaction.recurring_donor.id
      })
    end

    payload
  end
end
