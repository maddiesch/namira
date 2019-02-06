require 'sinatra/base'

class EchoAPI < Sinatra::Base
  post '/status/:status' do
    request.body.rewind
    json_response(
      params[:status].to_i,
      headers: request.env.select { |k, _| k =~ /^HTTP_/ },
      body: request.body.read
    )
  end

  private

  def json_response(response_code, body)
    content_type :json
    status response_code
    JSON.dump(body)
  end
end
