# frozen_string_literal: true

module TiktokBusinessApi
  # Main client for interacting with the TikTok Business API
  class Client
    # @return [TiktokBusinessApi::Config] Client configuration
    attr_reader :config

    # @return [TiktokBusinessApi::Auth] Authentication handler
    attr_reader :auth

    # Initialize a new client
    #
    # @param options [Hash] Override configuration options
    def initialize(options = {})
      @config = TiktokBusinessApi.config.dup || Config.new

      # Override config with options
      options.each do |key, value|
        @config.send("#{key}=", value) if @config.respond_to?("#{key}=")
      end

      @auth = Auth.new(self)
      @resources = {}
    end

    # Get or create a resource instance
    #
    # @param resource_name [Symbol] Name of the resource
    # @return [BaseResource] Resource instance
    def resource(resource_name)
      @resources[resource_name] ||= begin
                                      # Convert resource_name to class name (e.g., :campaign => Campaign)
                                      class_name = resource_name.to_s.split('_').map(&:capitalize).join

                                      # Get the resource class
                                      resource_class = TiktokBusinessApi::Resources.const_get(class_name)

                                      # Create an instance
                                      resource_class.new(self)
                                    end
    end

    # Make an HTTP request to the TikTok Business API
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash] URL parameters for GET, or body parameters for POST/PUT
    # @param headers [Hash] Additional HTTP headers
    # @return [Hash] Parsed API response
    def request(method, path, params = {}, headers = {})
      url = File.join(@config.api_base_url, path)

      # Set up default headers
      default_headers = {
        'Content-Type' => 'application/json'
      }

      # Add access token if available
      if @config.access_token
        default_headers['Access-Token'] = @config.access_token
      end

      # Merge with custom headers
      headers = default_headers.merge(headers)

      # Log the request
      log_request(method, url, params, headers)

      # Build the request
      response = connection.run_request(method, url, nil, headers) do |req|
        case method
        when :get, :delete
          req.params = params
        when :post, :put
          req.body = JSON.generate(params) unless params.empty?
        end
      end

      # Parse and handle the response
      handle_response(response)
    end

    # Access to campaign resource
    #
    # @return [TiktokBusinessApi::Resources::Campaign] Campaign resource
    def campaigns
      resource(:campaign)
    end

    # Access to ad group resource
    #
    # @return [TiktokBusinessApi::Resources::Adgroup] Ad group resource
    def adgroups
      resource(:adgroup)
    end

    # Access to ad resource
    #
    # @return [TiktokBusinessApi::Resources::Ad] Ad resource
    def ads
      resource(:ad)
    end

    private

    # Set up Faraday connection
    #
    # @return [Faraday::Connection] Faraday connection
    def connection
      @connection ||= Faraday.new do |conn|
        conn.options.timeout = @config.timeout
        conn.options.open_timeout = @config.open_timeout

        # Set up middleware
        conn.use Faraday::Response::Logger, @config.logger if @config.logger
        conn.use Faraday::FollowRedirects::Middleware
        conn.use Faraday::Retry::Middleware, max: 3

        conn.adapter Faraday.default_adapter
      end
    end

    # Parse and handle the API response
    #
    # @param response [Faraday::Response] HTTP response
    # @return [Hash] Parsed response body
    # @raise [TiktokBusinessApi::Error] If the response indicates an error
    def handle_response(response)
      # Log the response
      log_response(response)

      # Parse the response body
      body = if response.body && !response.body.empty?
               begin
                 JSON.parse(response.body)
               rescue JSON::ParserError
                 { error: "Invalid JSON response: #{response.body}" }
               end
             else
               {}
             end

      # Check for API errors
      if !response.success? || (body.is_a?(Hash) && body['code'] != 0)
        raise ErrorFactory.from_response(response)
      end

      body
    end

    # Log the request details
    #
    # @param method [Symbol] HTTP method
    # @param url [String] Request URL
    # @param params [Hash] Request parameters
    # @param headers [Hash] Request headers
    def log_request(method, url, params, headers)
      return unless @config.debug && @config.logger

      @config.logger.debug "[TiktokBusinessApi] Request: #{method.upcase} #{url}"
      @config.logger.debug "[TiktokBusinessApi] Parameters: #{params.inspect}"
      @config.logger.debug "[TiktokBusinessApi] Headers: #{headers.inspect}"
    end

    # Log the response details
    #
    # @param response [Faraday::Response] HTTP response
    def log_response(response)
      return unless @config.debug && @config.logger

      @config.logger.debug "[TiktokBusinessApi] Response Status: #{response.status}"
      @config.logger.debug "[TiktokBusinessApi] Response Body: #{response.body}"
    end
  end
end