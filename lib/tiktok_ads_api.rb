# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'faraday/follow_redirects'
require 'json'

require_relative 'tiktok_ads_api/version'
require_relative 'tiktok_ads_api/config'
require_relative 'tiktok_ads_api/errors'
require_relative 'tiktok_ads_api/client'
require_relative 'tiktok_ads_api/auth'

# Resources
require_relative 'tiktok_ads_api/resources/base_resource'
require_relative 'tiktok_ads_api/resources/campaign'

module TiktokAdsApi
  class << self
    attr_accessor :config

    # Configure the TikTok Ads API client
    #
    # @yield [config] Configuration object that can be modified
    # @return [TiktokAdsApi::Config] The configuration object
    def configure
      self.config ||= Config.new
      yield(config) if block_given?
      config
    end

    # Create a new client instance
    #
    # @param options [Hash] Optional configuration overrides
    # @return [TiktokAdsApi::Client] A new client instance
    def client(options = {})
      TiktokAdsApi::Client.new(options)
    end
  end
end