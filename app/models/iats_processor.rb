class IatsProcessor < Processor
  def process(options)
    donor = Donor.find_by(external_id: options[:token])

    if donor.nil?
      success, response = add_donor(options[:metadata], options[:source])
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
      agent_code: api_key,
      password: api_secret,
      external_id: donor.external_id,
      amount: options[:amount]
    }

    response = IatsEft.charge_customer(charge_params)

    success = response[:authorizationresult]
    transaction = nil
    if success.include?('OK:')
      transaction = Transaction.create!(
        processor_id: id,
        amount: options[:amount],
        external_id: response[:transaction_id],
        status: 'pending',
        data: response[:response],
        donor: donor,
        source_system: options[:source]['system'] || donor.source_system || 'unkown',
        source_external_id: options[:source]['external_id'] || donor.source_external_id || 'unknown'
      )
    else
      return {
        status: 'rejected',
        message: response[:authorizationresult]
      }
    end

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
      processor_transaction_id: response[:transaction_id],
      transaction_id: transaction.id,
      status: 'approved',
      amount: transaction.amount,
      donor_id: donor.id,
      recurring: transaction.recurring
    }
  end

  def update_transactions_status(date)
    transactions = get_transactions(date)
    transactions.each do |transaction_data|
      transaction = Transaction.find_by(
        processor: self,
        external_id: transaction_data[:tnid]
      )

      if transaction
        transaction.update_attributes(
          status: transaction_data[:rst]
        )
      end
    end
  end

  private

  def get_transactions(date)
    transactions_params = {
      agent_code: api_key,
      password: api_secret,
      date: date.iso8601
    }

    approved_status, approved_transactions = IatsEft.get_transactions(transactions_params, 'approved')
    reject_status, reject_transactions = IatsEft.get_transactions(transactions_params, 'reject')
    return_status, return_transactions = IatsEft.get_transactions(transactions_params, 'return')

    all_transactions = []

    if approved_status && !approved_transactions.nil?
      all_transactions += approved_transactions
    end

    if reject_status && !reject_transactions.nil?
      all_transactions += reject_transactions
    end

    if return_status && !return_transactions.nil?
      all_transactions += return_transactions
    end

    all_transactions
  end

  def recurring_donor?(options, transaction)
    options[:recurring] &&
      options[:recurring_donor_id].nil? &&
      transaction.status == 'pending'
  end

  def add_donor(metadata = {}, source = {})
    metadata = metadata
    donor_params = {
      agent_code: api_key,
      password: api_secret,
      first_name: metadata[:first_name],
      last_name: metadata[:last_name],
      email: metadata[:email],
      account_number: metadata[:account_number],
      account_type: metadata[:account_type]
    }

    response = IatsEft.create_customer(donor_params)

    if response[:success]
      donor = Donor.create!(
        processor_id: id,
        external_id: response[:customercode],
        data: response[:response],
        metadata: metadata.reject { |key, _| key.eql?(:account_number) },
        source_system: source[:system] || 'unknown',
        source_external_id: source[:external_id] || 'unknown'
      )

      return [true, donor]
    else
      return [false, "Failed to create customer token"]
    end
  end
end
