class StripeProcessor < Processor
  def process(options)
    donor = Donor.find_by(external_id: options[:token])

    if donor.nil?
      success, response = add_donor(options[:token], options[:metadata], options[:source])
      if success
        donor = response
      else
        return {
          status: 'rejected',
          message: response
        }
      end
    end

    charge_params = {
      amount: options[:amount],
      currency: currency,
      customer: donor.external_id
    }

    charge_options = { api_key: api_secret, stripe_version: '2018-02-06' }
    if options[:idempotency_key].present?
      charge_options[:idempotency_key] = options[:idempotency_key]
    end

    begin
      charge = Stripe::Charge.create(
        charge_params,
        charge_options
      )
    rescue Stripe::CardError => e
      Rollbar.error(e)
      body = e.json_body
      err  = body[:error]
      return {
        status: 'rejected',
        # Using string interpolation to avoid "no implicit conversion of nil into String" errors if one of these values is nil.
        message: "#{err[:code]}, Decline Code: #{err[:decline_code]}"
      }
    end

    transaction = Transaction.new(
      processor_id: id,
      amount: charge.amount,
      external_id: charge.id,
      status: charge.status == 'succeeded' ? 'approved' : 'rejected',
      data: charge.to_json,
      donor: donor,
      source_system: options[:source].nil? ? donor.source_system : options[:source]['system'],
      source_external_id: options[:source].nil? ? donor.source_external_id : options[:source]['external_id']
    )

    if recurring_donor?(options, transaction)
      recurring_donor = add_recurring_donor(donor, charge.amount)
      options[:recurring_donor_id] = recurring_donor.id
    end

    if options[:recurring_donor_id]
      transaction.recurring_donor_id = options[:recurring_donor_id]
      transaction.recurring = true
    end

    transaction.save!

    {
      processor_transaction_id: charge.id,
      transaction_id: transaction.id,
      status: 'approved',
      amount: transaction.amount,
      donor_id: donor.id,
      recurring: transaction.recurring
    }
  end

  def process_webhook(params)
    puts params.inspect
  end

  def recurring_donor?(options, transaction)
    options[:recurring] &&
      options[:recurring_donor_id].nil? &&
      transaction.status == 'approved'
  end

  def add_donor(token, metadata = {}, source)
    metadata = metadata.permit!.to_hash unless metadata.empty?
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

    [true, donor]
  end

  def refund(token)
    refund_params = { charge: token }
    refund_options = { api_key: api_secret, stripe_version: '2018-02-06' }

    refund = Stripe::Refund.create(
      refund_params,
      refund_options
    )

    transaction = Transaction.find_by(
      processor: self,
      external_id: token
    )

    if transaction.recurring
      recurring_donor = RecurringDonor.find(transaction.recurring_donor_id)
      recurring_donor.update(
        ended_at: Time.now,
        last_fail_reason: 'Refund'
      )
    end
    transaction.update(
      status: 'refunded',
      data: refund.to_json
    )
  end
end
