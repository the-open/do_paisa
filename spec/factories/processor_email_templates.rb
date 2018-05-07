FactoryBot.define do
  factory :processor_email_template do
    sender_name "Tupac"
    sender_email "test@example.com"
    subject "Thanks {{first_name}}"
    html %Q{Dear {{first_name}},<br /><br />

    Thanks for your donation of {{amount}}."}

    processor { FactoryBot.create(:stripe_processor) }

    factory :one_off_success_email_template do 
      email_type :one_off_success
    end

    factory :one_off_fail_email_template do 
      email_type :one_off_fail
    end

    factory :recurring_start_email_template do 
      email_type :recurring_start
      html %Q{Dear {{first_name}},<br /><br />

      Thanks for your regular donation of {{amount}}. It will start on {{next_payment_date}}"}
    end

    factory :recurring_fail_email_template do 
      email_type :recurring_fail
      subject "Donation problem, {{first_name}}"
      html %Q{Dear {{first_name}},<br /><br />

      There's an issue with your regular donation: {{last_fail_reason}}."}
    end
  end
end
