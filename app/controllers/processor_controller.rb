class ProcessorController < ApplicationController
  def example
    @processor = Processor.where(id: params['id']).take!
    @api_key = params['api_key']
    processor_type = @processor.type.remove('Processor').downcase
    render "/#{processor_type}/example", layout: false
  end
end