class BamboraProcessor < Processor
  def process(options)

    # TODO: Not sure if this is correct for Bambora? Token will be different every time
    donor = Donor.find_by(id: options[:token])
    donor = add_donor(options[:token], options[:metadata]) if donor.nil?

    gateway = ActiveMerchant::Billing::BeanstreamGateway.new(
     :login => api_key,
     :secure_profile_api_key => api_secret
    )

    response = gateway.purchase(options[:amount], donor.external_id)

    transaction = Transaction.create!(
      processor_id: id,
      amount: 100*response.params['trnAmount'].to_f,
      external_id: response.params['trnId'],
      status: response.message,
      data: response.params.to_json,
      donor: donor
    )

    if recurring_donor?(options, transaction)
      recurring_donor = add_recurring_donor(donor, transaction.amount)
      options[:recurring_donor_id] = recurring_donor.id
    end

    if options[:recurring_donor_id]
      transaction.update_attributes(
        recurring_donor_id: options[:recurring_donor_id],
        recurring: true
      )
    end

    {
      transaction_id: transaction.id,
      status: transaction.status,
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
      transaction.status.eql?('succeeded')
  end

  def add_donor(token, metadata = {})
    # metadata = metadata.permit!.to_hash
    customer_params = {
      source: token,
      email: metadata["email"],
      metadata: metadata
    }

    gateway = ActiveMerchant::Billing::BeanstreamGateway.new(
     :login => api_key,
     :secure_profile_api_key => api_secret
    )

    options = {
      email: metadata["email"],
      card_owner: metadata["name"],
      billing_address: {
        name: metadata["name"],
        phone: metadata["phone"],
        address1: metadata["address1"],
        address2: metadata["address2"],
        city: metadata["city"],
        state: metadata["province"],
        zip: metadata["postal_code"],
        country: metadata["country"]
      }
    }

    response = gateway.store(token, options)

    p response
    # 17 = This customer already exists    
    if response.params['responseCode'] == '17'
      customer_vault_id = response.params['matchedCustomerCode']
    # 1 = Customer successfully created    
    elsif response.params['responseCode'] == '1'
      customer_vault_id = response.params['customer_vault_id']
    else
      raise BamboraProcessorCustomerCreateError, response.message
    end

    donor = Donor.find_or_create_by!(
      processor_id: id,
      external_id: customer_vault_id,
    )

    donor.update_attributes(      
      data: response.params.to_json,
      metadata: metadata
      )

    donor
  end
end

class BamboraProcessorCustomerCreateError < StandardError; end


