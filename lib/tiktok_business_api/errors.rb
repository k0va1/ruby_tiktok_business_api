# frozen_string_literal: true

module TiktokBusinessApi
  # Base error class for the TikTok Business API
  class Error < StandardError
    # @return [Integer] HTTP status code
    attr_reader :status_code

    # @return [Hash] Full response body
    attr_reader :body

    # @return [Hash] Request that caused the error
    attr_reader :request

    # Initialize a new error
    #
    # @param message [String] Error message
    # @param status_code [Integer] HTTP status code
    # @param body [Hash] Response body
    # @param request [Hash] Request that caused the error
    def initialize(message = nil, status_code = nil, body = nil, request = nil)
      @status_code = status_code
      @body = body
      @request = request
      super(message)
    end

    # TikTok return code from the response body (e.g. 40001, 40100, 50000).
    # TikTok answers most failures with HTTP 200 and a non-zero code.
    #
    # @return [Integer, nil] TikTok return code
    def code
      Integer(body["code"], exception: false) if body.is_a?(Hash)
    end

    # TikTok request id, the reference TikTok support asks for
    #
    # @return [String, nil] TikTok request id
    def request_id
      body["request_id"] if body.is_a?(Hash)
    end
  end

  # Error raised when authentication fails
  class AuthenticationError < Error; end

  # Error raised when authorization fails
  class AuthorizationError < Error; end

  # Error raised for invalid requests
  class InvalidRequestError < Error; end

  # Error raised for API errors
  class ApiError < Error; end

  # Error raised for rate limit errors
  class RateLimitError < Error; end

  # Factory for creating the appropriate error object
  class ErrorFactory
    # TikTok return codes that identify the failure whatever the HTTP status is
    CODE_CLASSES = {
      40_001 => AuthorizationError,
      40_100 => RateLimitError,
      40_105 => AuthenticationError
    }.freeze

    # TikTok return codes of server-side failures (internal error, internal timeout)
    SERVER_ERROR_CODES = (50_000..59_999)

    # Create an error object based on the response
    #
    # @param response [Faraday::Response] The HTTP response
    # @param request [Hash] The request that caused the error
    # @return [TiktokBusinessApi::Error] The appropriate error object
    def self.from_response(response, request = nil)
      status = response.status
      body = if response.body && !response.body.empty?
        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          {error: "Invalid JSON response: #{response.body}"}
        end
      else
        {}
      end

      # Parse TikTok API response which has its own error structure
      code = body.is_a?(Hash) ? Integer(body["code"], exception: false) : nil
      error_message = body.is_a?(Hash) ? body["message"] : nil

      # The TikTok return code wins: most failures come back as HTTP 200
      klass = class_for_code(code) || class_for_status(status)

      # Create and return the error
      klass.new(
        error_message || "HTTP #{status}",
        status,
        body,
        request
      )
    end

    # Error class of a TikTok return code, nil when the code alone does not tell
    #
    # @param code [Integer, nil] TikTok return code
    # @return [Class, nil] Error class
    def self.class_for_code(code)
      return if code.nil?

      CODE_CLASSES[code] || (ApiError if SERVER_ERROR_CODES.cover?(code))
    end

    # Error class of an HTTP status
    #
    # @param status [Integer] HTTP status code
    # @return [Class] Error class
    def self.class_for_status(status)
      case status
      when 401
        AuthenticationError
      when 403
        AuthorizationError
      when 429
        RateLimitError
      when 400..499
        InvalidRequestError
      when 500..599
        ApiError
      else
        Error
      end
    end
  end
end
