# frozen_string_literal: true

class PaypalProcessor < Processor
  def process(options)
    donor = Donor.where(external_id: options[:token]).take!
    return if donor.blank?

    client = paypal_client

    response = client.do_reference_transaction(charge_params(client, options, donor))

    return error_response(response.errors, donor) if response.errors.any?

    transaction = create_transaction(response, options[:recurring_donor_id], donor)

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

  private

  def charge_params(client, options, donor)
    client.build_do_reference_transaction(
      DoReferenceTransactionRequestDetails: {
        ReferenceID: donor.external_id,
        PaymentAction: 'Sale',
        PaymentDetails: {
          OrderTotal: {
            currencyID: currency,
            value: options[:amount].to_i / 100
          },
          Custom: options[:custom],
          OrderDescription: options[:order_description]
        }
      }
    )
  end

  def error_response(errors, donor)
    Rollbar.error("#{errors[0].short_message} - #{errors[0].long_message}: #{donor.metadata}, #{donor.id}")
    {
      status: 'rejected',
      message: "#{errors[0].short_message} - #{errors[0].long_message}"
    }
  end

  def create_transaction(response, recurring_donor_id, donor)
    transaction_details = response.do_reference_transaction_response_details

    Transaction.create!(
      processor_id: id,
      amount: transaction_details.amount.value * 100,
      external_id: transaction_details.transaction_id,
      status: 'approved',
      data: response.to_hash.to_json,
      donor: donor,
      source_system: donor.source_system,
      source_external_id: donor.source_external_id,
      recurring: true,
      recurring_donor_id: recurring_donor_id
    )
  end

  def paypal_client
    configure_paypal_sdk
    PayPal::SDK::Merchant.new
  end

  def configure_paypal_sdk
    PayPal::SDK.configure(
      mode: 'live',
      username: api_key,
      password: api_secret,
      signature: parsed_config.dig('signature'),
      subject: parsed_config.dig('subject'),
      ssl_options: { ca_file: nil }
    )
  end

  def parsed_config
    JSON.parse config
  rescue JSON::ParserError => ex
    Rollbar.error(ex)
    {}
  end
end
