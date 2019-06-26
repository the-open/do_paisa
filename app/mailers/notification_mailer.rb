class NotificationMailer < ApplicationMailer
  default from: 'notifications@example.com'
  before_action :set_vars

  rescue_from ActiveRecord::RecordNotFound do |exception|
    if params.dig(:retries).to_i > 3
      Rollbar.error(exception)
    else
      params[:retries] = params.dig(:retries).to_i + 1
      NotificationMailer.with(params).send(action_name).deliver_later(wait: 3.minutes)
    end
  end

  def one_off_approved
    return if @vars.blank?
    return unless template = @processor.processor_email_templates.find_by(email_type: 'one_off_approved')
    send_rendered(template, @vars)
  end

  def one_off_pending
    return if @vars.blank?
    return unless template = @processor.processor_email_templates.find_by(email_type: 'one_off_pending')
    send_rendered(template, @vars)
  end

  def one_off_pending_rejected
    return if @vars.blank?
    return unless template = @processor.processor_email_templates.find_by(email_type: 'one_off_pending_rejected')
    send_rendered(template, @vars)
  end

  def recurring_started
    return if @vars.blank?
    return unless template = @processor.processor_email_templates.find_by(email_type: 'recurring_start')
    send_rendered(template, @vars)
  end

  def recurring_fail
    return if @vars.blank?
    return unless template = @processor.processor_email_templates.find_by(email_type: 'recurring_fail')
    send_rendered(template, @vars)
  end

  private

  def set_vars
    if params[:transaction_id].present?
      return unless @transaction = Transaction.find(params[:transaction_id])

      @recurring_donor = @transaction.recurring_donor
      @donor = @transaction.donor
      @processor = @transaction.processor
    elsif params[:recurring_donor_id]
      @recurring_donor = RecurringDonor.find(params[:recurring_donor_id])
      return if @recurring_donor.blank?

      @donor = @recurring_donor.donor
      @processor = @recurring_donor.processor
    end

    @email = @donor.metadata['email']
    amount = '$' + '%.2f' % ((@transaction.try(:amount) || @recurring_donor.try(:amount)).to_f / 100)

    @vars = {
      first_name: @donor.metadata['first_name'],
      last_name: @donor.metadata['last_name'],
      email: @donor.metadata['email'],
      amount: amount
    }

    if @recurring_donor.present?
      @vars.merge!(@recurring_donor.attributes.symbolize_keys.slice(:last_fail_reason, :next_charge_at))
    end
  end

  def send_rendered(template, vars)
    subject = template.render_subject(vars)
    html = template.render_html(vars)
    from = "#{template.sender_name} <#{template.sender_email}>"

    mail(
      to: @email,
      subject: subject,
      body: html,
      content_type: 'text/html',
      from: from
    )

    DonorEmail.create!(donor: @donor, subject: subject, html: html, sender_name: template.sender_name, sender_email: template.sender_email)
  end
end
