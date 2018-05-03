class IatsEft
  def self.create_customer(options)
    client = Savon.client(
      wsdl: 'https://www.iatspayments.com/netgate/CustomerLinkv2.asmx?WSDL',
      soap_version: 2
    )

    request_params = {
      agentCode: options[:agent_code],
      password: options[:password],
      firstName: options[:first_name],
      lastName: options[:last_name],
      email: options[:email],
      accountNum: options[:account_number],
      accountType: options[:account_type] || 'SAVING',
      recurring: 0, # False
      beginDate: Time.now.iso8601, # Bogus Time Zone Required
      endDate: Time.now.iso8601 # Same as above
    }

    response = client.call(
      :create_acheft_customer_code,
      message: request_params
    )

    puts response.body

    if response.success?
      iatsresponse = response.body[:create_acheft_customer_code_response][:create_acheft_customer_code_result][:iatsresponse]
      errors = iatsresponse[:errors]
      authorizationresult = iatsresponse[:processresult][:authorizationresult]
      if errors.nil? && authorizationresult.eql?('OK')
        return {
          customercode: iatsresponse[:processresult][:customercode],
          response: response.body.to_json,
          success: true
        }
      else
        return {
          success: false
        }
      end
    else
      return {
        success: false
      }
    end
  end

  def self.charge_customer(options)
    client = Savon.client(
      wsdl: 'https://www.iatspayments.com/netgate/ProcessLinkv2.asmx?WSDL',
      soap_version: 2
    )

    request_params = {
      agentCode: options[:agent_code],
      password: options[:password],
      customerCode: options[:external_id],
      total: options[:amount]
    }

    response = client.call(
      :process_acheft_with_customer_code,
      message: request_params
    )

    if response.success?
      iatsresponse = response.body[:process_acheft_with_customer_code_response][:process_acheft_with_customer_code_result][:iatsresponse]

      errors = iatsresponse[:errors]
      if errors.nil? && iatsresponse[:processresult][:authorizationresult].include?('OK')
        processresult = iatsresponse[:processresult]
        return {
          authorizationresult: processresult[:authorizationresult],
          transaction_id: processresult[:transactionid].delete("\n"),
          response: response.body.to_json
        }
      else
        return {
          authorizationresult: iatsresponse[:processresult][:authorizationresult],
          transaction_id: iatsresponse[:processresult][:transactionid],
          response: response.body.to_json
        }
      end
    end
  end

  def self.get_transactions(options, type)
    client = report_client

    response = client.call(
      "get_acheft_#{type}_specific_date_xml".to_sym,
      message: get_params(options)
    )

    parse_response(response.body, type)
  end

  class << self
    private

    def parse_response(response, type)
      iatsresponse = response["get_acheft_#{type}_specific_date_xml_response".to_sym]["get_acheft_#{type}_specific_date_xml_result".to_sym][:iatsresponse]

      if iatsresponse[:errors].nil?
        return [true, nil] if iatsresponse[:journalreport].nil?
        transactions = iatsresponse[:journalreport][:tn]
        return [true, [transactions].flatten]
      else
        return [false, iatsresponse[:errors]]
      end
    end

    def report_client
      if @report_client.nil?
        @report_client = Savon.client(
          wsdl: 'https://www.iatspayments.com/netgate/ReportLinkv2.asmx?WSDL',
          soap_version: 2
        )
      end
      @report_client
    end

    def get_params(options)
      {
        agentCode: options[:agent_code],
        password: options[:password],
        date: options[:date]
      }
    end
  end
end
