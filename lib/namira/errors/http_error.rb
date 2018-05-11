module Namira
  module Errors
    ##
    # HTTP Error
    #
    # Any non 2xx status code will raise this error.
    class HTTPError < BaseError
      ##
      # @return [Integer] The HTTP status that caused the error
      attr_reader :status

      ##
      # @return [Namira::Response] The HTTP response
      attr_reader :response

      ##
      # Returns a new instance of HTTPError
      #
      # @param msg [String] The error message. e.g. "http_error/500"
      # @param status [Integer] The HTTP status that caused the error
      # @param response [Namira::Response] The HTTP response
      def initialize(msg, status, response)
        @status = status
        @response = response
        super(msg)
      end

      class << self
        ##
        # Returns a new HTTP Error based on the status
        def create(response)
          klass_for_status(response.status).new("http_error/#{response.status}", response.status, response)
        end

        private

        def klass_for_status(status)
          name = STATUS_MAPPING[status.to_i.to_s]
          return HTTPError if name.nil?
          klass_name = "#{name.tr(' ', '')}Error"
          begin
            HTTPError.const_get(klass_name)
          rescue NameError
            klass = Class.new(HTTPError) {}
            HTTPError.const_set(klass_name, klass)
            retry
          end
        end
      end

      STATUS_MAPPING = {
        '300' => 'Multiple Choices',
        '301' => 'Moved Permanently',
        '302' => 'Found',
        '303' => 'See Other',
        '304' => 'Not Modified',
        '305' => 'Use Proxy',
        '306' => 'Switch Proxy',
        '307' => 'Temporary Redirect',
        '308' => 'Permanent Redirect',
        '400' => 'Bad Request',
        '401' => 'Unauthorized',
        '402' => 'Payment Required',
        '403' => 'Foridden',
        '404' => 'Not Found',
        '405' => 'Method Not Allowed',
        '406' => 'Not Acceptable',
        '407' => 'Proxy Authentication Required',
        '408' => 'Request Timeout',
        '409' => 'Conflict',
        '410' => 'Gone',
        '411' => 'Length Required',
        '412' => 'Precondition Failed',
        '413' => 'Payload Too Large',
        '414' => 'URI Too Long',
        '415' => 'Unsupported Media Type',
        '416' => 'Range Not Satisfiable',
        '417' => 'Expectation Failed',
        '418' => "Im A Teapot",
        '421' => 'Misdirected Request',
        '422' => 'Unprocessable Entity',
        '423' => 'Locked',
        '424' => 'Failed Dependency',
        '426' => 'Upgrade Required',
        '428' => 'Precondition Required',
        '429' => 'Too Man Requests',
        '431' => 'Request Header Fields Too Large',
        '451' => 'Unavailable For Legal Reasons',
        '500' => 'Internal Server Error',
        '501' => 'Not Implemented',
        '502' => 'Bad Gateway',
        '503' => 'Service Unavailable',
        '504' => 'Gateway Timeout',
        '505' => 'HTTP Version Not Supported',
        '506' => 'Variant Also Negotiates',
        '507' => 'Insufficient Storage',
        '508' => 'Loop Detected',
        '510' => 'Not Extended',
        '511' => 'Network Authentication Required'
      }.freeze
    end
  end
end
