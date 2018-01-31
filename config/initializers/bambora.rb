## This monkey patch is necessary to be able to create customers

# This forces Rails to load the class first, otherwise we'd lose our patch
ActiveMerchant::Billing::BeanstreamGateway.new(login: 'bla')

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module BeanstreamCore
      def add_address(post, options)
        p "This is loading!"
        post[:ordEmailAddress]  = options[:email] if options[:email]
        post[:shipEmailAddress] = options[:shipping_email] || options[:email] if options[:email]
        # Next line is the monkey patch
        post[:trnCardOwner] = options[:card_owner] if options[:card_owner]

        prepare_address_for_non_american_countries(options)

        if billing_address = options[:billing_address] || options[:address]
          post[:ordName]          = billing_address[:name]
          post[:ordPhoneNumber]   = billing_address[:phone]
          post[:ordAddress1]      = billing_address[:address1]
          post[:ordAddress2]      = billing_address[:address2]
          post[:ordCity]          = billing_address[:city]
          post[:ordProvince]      = state_for(billing_address)
          post[:ordPostalCode]    = billing_address[:zip]
          post[:ordCountry]       = billing_address[:country]
        end

        if shipping_address = options[:shipping_address]
          post[:shipName]         = shipping_address[:name]
          post[:shipPhoneNumber]  = shipping_address[:phone]
          post[:shipAddress1]     = shipping_address[:address1]
          post[:shipAddress2]     = shipping_address[:address2]
          post[:shipCity]         = shipping_address[:city]
          post[:shipProvince]     = state_for(shipping_address)
          post[:shipPostalCode]   = shipping_address[:zip]
          post[:shipCountry]      = shipping_address[:country]
          post[:shippingMethod]   = shipping_address[:shipping_method]
          post[:deliveryEstimate] = shipping_address[:delivery_estimate]
        end
      end
    end
  end
end