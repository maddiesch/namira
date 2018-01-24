module Namira
  ##
  # The calling environment for the request
  class Env
    attr_accessor \
      :uri,
      :headers,
      :body,
      :method,
      :config,
      :redirect_count,
      :response,
      :timing

    def initialize(env)
      @uri     = Addressable::URI.parse(env[:uri].to_s)
      @body    = env[:body]
      @method  = env[:method]
      @headers = Hash(env[:headers])
      @config  = Hash(env[:config])
      @redirect_count = 0
      @response = nil
      @timing = nil
    end
  end
end
