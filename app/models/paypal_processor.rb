# frozen_string_literal: true

class PaypalProcessor < Processor
  def process(options)
    donor = Donor.where(external_id: options[:token]).take!

    extra_config = JSON.parse(config)

    PayPal::SDK.configure(
      mode: 'live',
      username: api_key,
      password: api_secret,
      signature: extra_config['signature'],
      subject: extra_config['subject']
    )

    client = PayPal::SDK::Merchant.new

    charge_params = client.build_do_reference_transaction(
      DoReferenceTransactionRequestDetails: {
        ReferenceID: donor.external_id,
        PaymentAction: 'Sale',
        PaymentDetails: {
          OrderTotal: {
            currencyID: currency,
            value: options[:amount].to_i / 100
          }
        }
      }
    )

    response = client.do_reference_transaction(charge_params)

    if response.errors.any?
      Rollbar.error(response.Errors)
      puts 'Failed to process transaction'
      puts response.Errors
      return
    end

    transaction_details = response.do_reference_transaction_response_details

    transaction = Transaction.create!(
      processor_id: id,
      amount: transaction_details.amount.value,
      external_id: transaction_details.transaction_id,
      status: 'approved',
      data: response.to_hash.to_json,
      donor: donor,
      source_system: donor.source_system,
      source_external_id: donor.source_external_id,
      recurring: true,
      recurring_donor_id: options[:recurring_donor_id]
    )

    {
      processor_transaction_id: transaction.external_id,
      transaction_id: transaction.id,
      status: 'approved',
      amount: transaction.amount,
      donor_id: donor.id,
      recurring: transaction.recurring
    }
  end

  def add_donor(token, metadata = {}, source, amount, date)
    donor = Donor.create!(
      processor_id: id,
      external_id: token,
      metadata: metadata,
      source_system: source[:system] || 'PayPal EN',
      source_external_id: source[:external_id] || 'PayPal EN'
    )

    add_recurring_donor(donor, amount, date)

    [true, donor]
  end
end
