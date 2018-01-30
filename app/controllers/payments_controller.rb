class PaymentsController < ApiController
  before_action :api_key
  
  def pay
    allowed_origin_uri = URI(@api_user.allowed_origin)
    allowed_host = "#{allowed_origin_uri.host}:#{allowed_origin_uri.port}"

    response.headers['Content-Security-Policy'] = "frame-ancestors #{allowed_host}"
    response.headers['X-Frame-Options'] = "ALLOW-FROM #{@api_user.allowed_origin}"
    @processor = Processor.where(id: params['id']).take!
    if request.post?
      process_params = {
        token: params[:token],
        amount: params[:amount],
        metadata: params[:metadata],
        recurring: params[:recurring]
      }
      transaction_response = @processor.process(process_params)
      render json: transaction_response, status: 200
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
