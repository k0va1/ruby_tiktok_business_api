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
      body.is_a?(Hash) ? body["code"] : nil
      error_message = body.is_a?(Hash) ? body["message"] : nil

      # Determine the error class based on status and error code
      klass = case status
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

      # Create and return the error
      klass.new(
        error_message || "HTTP #{status}",
        status,
        body,
        request
      )
    end
  end
end
