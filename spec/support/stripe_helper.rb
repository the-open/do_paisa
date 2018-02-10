def get_stripe_token
  Stripe::Token.create({
    :card => {
      :number => "4242424242424242",
      :exp_month => 2,
      :exp_year => 2019,
      :cvc => "314"
    }
  },
  { api_key: ENV['STRIPE_TEST_SECRET_KEY'] }
  )
end