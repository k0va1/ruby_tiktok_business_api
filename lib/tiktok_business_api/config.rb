# frozen_string_literal: true

module TiktokBusinessApi
  # Configuration class for TikTok Business API
  class Config
    # @return [String] TikTok API app ID
    attr_accessor :app_id

    # @return [String] TikTok API app secret
    attr_accessor :secret

    # @return [String] TikTok API access token
    attr_accessor :access_token

    # @return [String] Base URL for the TikTok API
    attr_accessor :api_base_url

    # @return [Boolean] Whether to enable debug logging
    attr_accessor :debug

    # @return [Object] Custom logger instance
    attr_accessor :logger

    # @return [Integer] Request timeout in seconds
    attr_accessor :timeout

    # @return [Integer] Open timeout in seconds
    attr_accessor :open_timeout

    # Initialize configuration with default values
    def initialize
      @api_base_url = 'https://business-api.tiktok.com/open_api/'
      @debug = false
      @timeout = 60
      @open_timeout = 30
    end
  end
end
