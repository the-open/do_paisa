class StripeProcessor < Processor
  def process(options)
    donor = Donor.find_by(token: options[:token])

    if donor.nil?
      success, response = add_donor(options[:token], options[:metadata], options[:source])
      if success 
        donor = response
      else
        return {
          status: "rejected",
          message: response
        }
      end
    end

    charge_params = {
      amount: options[:amount],
      currency: currency,
      customer: donor.external_id
    }

    charge_options = { api_key: api_secret, stripe_version: "2018-02-06" }
    if options[:idempotency_key].present?
      charge_options[:idempotency_key] = options[:idempotency_key]
    end

    charge = Stripe::Charge.create(
      charge_params,
      charge_options
    )

    transaction = Transaction.create!(
      processor_id: id,
      amount: charge.amount,
      external_id: charge.id,
      status: charge.status == 'succeeded' ? 'approved' : 'rejected',
      data: charge.to_json,
      donor: donor,
      source_system: options[:source]['system'] || donor.source_system,
      source_external_id: options[:source]['external_id'] || donor.source_external_id
    )

    if recurring_donor?(options, transaction)
      recurring_donor = add_recurring_donor(donor, charge.amount)
      options[:recurring_donor_id] = recurring_donor.id
    end

    if options[:recurring_donor_id]
      transaction.update_attributes(
        recurring_donor_id: options[:recurring_donor_id],
        recurring: true
      )
    end

    {
      processor_transaction_id: charge.id,
      transaction_id: transaction.id,
      status: "approved",
      amount: transaction.amount,
      donor_id: donor.id,
      recurring: transaction.recurring
    }
  end

  def process_webhook(params)
    puts params.inspect
  end

  private

  def recurring_donor?(options, transaction)
    options[:recurring] &&
      options[:recurring_donor_id].nil? &&
      transaction.status == 'approved'
  end

  def add_donor(token, metadata = {}, source)
    metadata = metadata.permit!.to_hash
    customer_params = {
      source: token,
      email: metadata['email'],
      metadata: metadata
    }
    
    begin
      customer = Stripe::Customer.create(
        customer_params,
        api_key: api_secret
      )
    rescue Stripe::CardError => e
      return [false, e.message]
    end
      

    donor = Donor.create!(
      token: token,
      processor_id: id,
      external_id: customer.id,
      data: customer.to_json,
      metadata: metadata,
      source_system: source['system'] || 'unknown',
      source_external_id: source['external_id'] || 'unknown'
    )

    return [true, donor]
  end
end
