# frozen_string_literal: true

class BamboraProcessor < Processor
  def process(options)
    # TODO: Not sure if this is correct for Bambora? Token will be different every time
    donor = Donor.find_by(id: options[:token])
    p "OPTINOS"
    p options
    donor = add_donor(options[:token], options[:metadata], options[:source]) if donor.nil?

    config_data = JSON.parse(config) if config

    gateway = ActiveMerchant::Billing::BeanstreamGateway.new(
      login: api_key,
      user: config_data['user'],
      password: config_data['password']
    )

    response = gateway.purchase(options[:amount], donor.external_id)

    transaction = Transaction.create!(
      processor_id: id,
      amount: 100 * response.params['trnAmount'].to_f,
      external_id: response.params['trnId'],
      status: response.message,
      data: response.params.to_json,
      donor: donor,
      source_system: options[:source]['system'] || donor.source_system,
      source_external_id: options[:source]['external_id'] || donor.source_external_id
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
      transaction.status.eql?('approved')
  end

  def add_donor(token, metadata = {}, source)
    # TODO: use require here to ensure that all the metadata required is included
    # metadata = metadata.permit!.to_hash

    gateway = ActiveMerchant::Billing::BeanstreamGateway.new(
      login: api_key,
      secure_profile_api_key: api_secret
    )

    options = {
      email: metadata['email'],
      card_owner: metadata['name'],
      billing_address: {
        name: metadata['name'],
        phone: metadata['phone'],
        address1: metadata['address1'],
        address2: metadata['address2'],
        city: metadata['city'],
        state: metadata['province'],
        zip: metadata['postcode'],
        country: metadata['country']
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

    donor = Donor.find_or_initialize_by(
      processor_id: id,
      external_id: customer_vault_id
    )

    donor.update_attributes(
      data: response.params.to_json,
      metadata: metadata,
      source_system: source['system'] || 'unknown',
      source_external_id: source['external_id'] || 'unknown'
    )
    donor.save!

    donor
  end
end

class BamboraProcessorCustomerCreateError < StandardError; end
