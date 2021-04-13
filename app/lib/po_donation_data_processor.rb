class PODonationDataProcessor

  DEFAULT_REQUIRED_KEYS = %w[Email GiftType ReferenceNumber]

  def process(payload)
    raise ArgumentError.new('No request payload') unless payload

    validate_required_keys!(required: DEFAULT_REQUIRED_KEYS, params: payload)

    ApplicationRecord.transaction do

      if payload['GiftType'] == 'PAC' || payload['GiftType'] == 'REA' || payload['GiftType'] == 'OTG'
        create_donation(payload)
      elsif payload['GiftType'] == 'UPG'
        upgrade_donation(payload)
      else
        raise "PO #{payload['ReferenceNumber']} has unrecognized gift type: #{payload['GiftType']}"
      end
    end

    return true
  end

  def upgrade_donation(payload)
    donor = Donor.find_by("metadata->>'email' = ?", payload['Email'])
    case payload['PaymentMethod']
    when 'V', 'M'
      amount = payload['OriginalAmount'].to_i*100
      processor = StripeProcessor.find_by(name: ENV['STRIPE_PROCESSOR_NAME'])
      recurring_donor = RecurringDonor.find_by(donor_id: donor.id, processor_id: processor.id, ended_at: nil, amount: amount)
    when 'C'
      amount = payload['OriginalAmount'].to_i*100
      processor = IatsProcessor.find_by(name: ENV['IATS_PROCESSOR_NAME'])
      recurring_donor = RecurringDonor.find_by(donor_id: donor.id, processor_id: processor.id, ended_at: nil, amount: amount)
    else
      raise "PO #{payload['ReferenceNumber']} has unrecognized payment method: #{payload['PaymentMethod']}"
    end

    if recurring_donor
      recurring_donor.update!(amount: payload['TotalAmount'].to_i*100)
    else
      create_donation(payload)
      recurring_donor = RecurringDonor.find_by(donor_id: donor.id, ended_at: nil, amount: amount)
      recurring_donor.update!(ended_at: Time.now())
    end
  end

  def create_donation(payload)
    po_guid = "PO-#{payload['ReferenceNumber']}"
    existing_donor = Donor.find_by("metadata->>'po_guid' = ?", po_guid)

    raise "Donor with PO GUID #{po_guid} already exists: #{existing_donor}" if existing_donor

    case payload['PaymentMethod']
    when 'V', 'M'
      payload = create_stripe_token(payload)
      processor = StripeProcessor.find_by(name: ENV['STRIPE_PROCESSOR_NAME'])
    when 'C'
      payload = parse_iats_payload(payload)
      processor = IatsProcessor.find_by(name: ENV['IATS_PROCESSOR_NAME'])
    else
      raise "PO #{payload['ReferenceNumber']} has unrecognized payment method: #{payload['PaymentMethod']}"
    end

    if payload[:date]
      success, donor = [true, Donor.find_by(external_id: payload[:token])]
      success, donor = processor.add_donor(payload[:token], payload[:metadata], payload[:source]) unless donor
      if success
        recurring_donor = processor.add_recurring_donor(donor, payload[:amount], payload[:date])
      end
    else
      transaction_response = processor.process(payload)
    end
  end

  def create_stripe_token(payload)
    processor = StripeProcessor.find_by(name: ENV['STRIPE_PROCESSOR_NAME'])
    Stripe.api_key = processor.api_secret
    required_keys = DEFAULT_REQUIRED_KEYS + %w[CARDNO CCExpiry]
    validate_required_keys!(required: required_keys, params: payload)

    unless payload['CARDNO'].present? && payload['CCExpiry'].present?
      raise "PO Import: payload incomplete, missing credit card info. Provided payload was: #{payload}"
    end

    exp_date = payload['CCExpiry']
    exp_month = exp_date.partition('/').first
    exp_year = exp_date.partition('/').last
    stripe_data = Stripe::Token.create({
      card: {
        number: payload['CARDNO'],
        exp_month: exp_month,
        exp_year: exp_year,
        name: payload['NameOnAccount'],
        address_line1: payload['StreetAddress'],
        address_city: payload['City'],
        address_state: payload['Province'],
        address_zip: payload['PostalCode'],
      },
    })
    parsed_payload = parse_stripe_payload(payload, stripe_data)
  end

  def parse_stripe_payload(payload, stripe_data)
    parsed_payload = {
      token: stripe_data[:id],
      idempotency_key: SecureRandom.uuid,
      metadata: {
        address_line1: payload['StreetAddress'],
        address_city: payload['City'],
        address_state: payload['Province'],
        address_zip: payload['PostalCode'],
        first_name: payload['FirstName'],
        last_name: payload['LastName'],
        email: payload['Email'],
        phone: payload['Phone'],
        po_guid: "PO-#{payload['ReferenceNumber']}"
      },
      source: {
        "system" => "PO CSV Upload",
        "external_id" => "Internal PO CSV Upload"
      }
    }
    if payload['PACStartDate'].present?
      parsed_payload[:date] = Date.parse(payload['PACStartDate'], "%d/%m/%Y")
    end
    if payload['GiftType'] == 'PAC' || payload['GiftType'] == 'REA'
      parsed_payload[:recurring] = true
      parsed_payload[:amount] = payload['PACAmount'].to_i*100
    elsif payload['GiftType'] == 'OTG'
      parsed_payload[:recurring] = false
      parsed_payload[:amount] = payload['OTGAmount'].to_i*100
    elsif payload['GiftType'] == 'UPG'
      parsed_payload[:recurring] = false
      parsed_payload[:amount] = payload['TotalAmount'].to_i*100
    end
    parsed_payload
  end

  def parse_iats_payload(payload)
    required_keys = DEFAULT_REQUIRED_KEYS + %w[BankINS BankTransit BankAccount]
    validate_required_keys!(required: required_keys, params: payload)

    unless payload['BankINS'].present? && payload['BankTransit'].present? && payload['BankAccount']
      raise "PO Import: payload incomplete, missing account info. Provided payload was: #{payload}"
    end


    parsed_payload = {
      metadata: {
        address_line1: payload['StreetAddress'],
        address_city: payload['City'],
        address_state: payload['Province'],
        address_zip: payload['PostalCode'],
        first_name: payload['FirstName'],
        last_name: payload['LastName'],
        email: payload['Email'],
        phone: payload['Phone'],
        po_guid: "PO-#{payload['ReferenceNumber']}",
        account_number: payload['BankINS'] + payload['BankTransit'] + payload['BankAccount'],
        account_type: 'CHECKING'
      },
      source: {
        system: "PO CSV Upload",
        external_id: "Internal PO CSV Upload"
      }
    }
    if payload['PACStartDate'].present?
      parsed_payload[:date] = Date.parse(payload['PACStartDate'], "%d/%m/%Y")
    end
    if payload['GiftType'] == 'PAC' || payload['GiftType'] == 'REA'
      parsed_payload[:recurring] = true
      parsed_payload[:amount] = payload['PACAmount'].to_i*100
    elsif payload['GiftType'] == 'OTG'
      parsed_payload[:recurring] = false
      parsed_payload[:amount] = payload['OTGAmount'].to_i*100
    elsif payload['GiftType'] == 'UPG'
      parsed_payload[:recurring] = false
      parsed_payload[:amount] = payload['TotalAmount'].to_i*100
    end
    parsed_payload
  end

  def validate_required_keys!(required:, params:)
    unless required.all? { |k| params.key?(k) }
      missing_keys = required - params.keys
      raise "PO Import: payload incomplete, missing field(s): #{missing_keys}. Provided fields were: #{params.keys}"
    end
  end
end
