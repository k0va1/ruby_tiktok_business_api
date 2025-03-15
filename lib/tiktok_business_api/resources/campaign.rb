# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Campaign resource for the TikTok Business API
    class Campaign < CrudResource
      # Get the resource name (used for endpoint paths and parameter names)
      #
      # @return [String] Resource name
      def resource_name
        'campaign'
      end

      # Override ID parameter name to match the API expectations
      def id_param_name
        'campaign_id'
      end

      # Override IDs parameter name to match the API expectations
      def ids_param_name
        'campaign_ids'
      end

      # Get a campaign by ID
      # Custom implementation to maintain backward compatibility
      #
      # @param advertiser_id [String] Advertiser ID
      # @param campaign_id [String] Campaign ID
      # @return [Hash] Campaign data
      def get_campaign(advertiser_id, campaign_id)
        params = {
          advertiser_id: advertiser_id,
          campaign_ids: [campaign_id]
        }

        response = _http_get(list_path, params)
        campaigns = response.dig('data', 'list') || []
        campaigns.first
      end

      def list(advertiser_id:, filtering: {}, page_size: nil, page: nil, **other_params, &block)
        super(filtering: filtering, page_size: page_size, page: page, **other_params.merge(advertiser_id: advertiser_id), &block)
      end

    end
  end
end