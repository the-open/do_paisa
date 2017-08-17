class PaymentsController < ApiController
  def pay
    @processor = Processor.where(id: params['id']).take!
    if request.post?
      process_params = {
        token: params[:token],
        amount: params[:amount],
        metadata: params[:metadata]
      }
      transaction_response = @processor.process(process_params)
      render json: transaction_response, status: 200
    else
      processor_type = @processor.type.remove('Processor').downcase
      @stripe_publishable_key = @processor.api_key
      render "/#{processor_type}/pay", layout: false
    end
  end
end
