class PaymentsController < ApiController
  before_action :api_key
  
  def pay
    allowed_origin_uri = URI(@api_user.allowed_origin)
    allowed_host = "#{allowed_origin_uri.host}:#{allowed_origin_uri.port}"

    response.headers['Content-Security-Policy'] = "frame-ancestors #{@api_user.allowed_origin}"
    response.headers['X-Frame-Options'] = "ALLOW-FROM #{@api_user.allowed_origin}"
    @processor = Processor.where(id: params['id']).take!
    if request.post?
      if params[:date]
        success, donor = [true, Donor.find_by(external_id: params[:token])]
        success, donor = @processor.add_donor(params[:metadata], params[:source]) unless donor

        if success
          recurring_donor = @processor.add_recurring_donor(donor, params[:amount], Date.parse(params[:date]))
          render json: {
            status: "approved",
            date: recurring_donor.next_charge_at.strftime("%d-%m-%Y")
          }
        else
          return {
            error: "This is a fail"
          }
        end
      else
        process_params = {
          token: params[:token],
          amount: params[:amount],
          metadata: params[:metadata],
          source: params[:source],
          recurring: params[:recurring],
          idempotency_key: params[:idempotency_key]
        }
        transaction_response = @processor.process(process_params)
        render json: transaction_response, status: 200
      end
    else
      processor_type = @processor.type.remove('Processor').downcase
      @stripe_publishable_key = @processor.api_key
      render "/#{processor_type}/pay", layout: false
    end
  end
  
  private

  def api_key
    @api_user = ApiUser.find_by(key: params['key'])
    if @api_user.nil?
      render body: nil, status: 401
      return
    end
  end
end
