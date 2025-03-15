# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Campaign resource for the TikTok Business API
    class Campaign < BaseResource
      # Create a new campaign
      #
      # @param advertiser_id [String] Advertiser ID
      # @param params [Hash] Campaign parameters
      # @return [Hash] New campaign data
      def create(advertiser_id, params = {})
        # Ensure advertiser_id is included in the params
        params = params.merge(advertiser_id: advertiser_id)

        response = post('create/', params)
        response['data']
      end

      # Get a list of campaigns
      #
      # @param advertiser_id [String] Advertiser ID
      # @param params [Hash] Filter parameters
      # @return [Hash] Campaign list response
      def list(advertiser_id, params = {})
        # Ensure advertiser_id is included in the params
        params = params.merge(advertiser_id: advertiser_id)

        response = _http_get('get/', params)
        response['data']
      end

      # Get a campaign by ID
      #
      # @param advertiser_id [String] Advertiser ID
      # @param campaign_id [String] Campaign ID
      # @return [Hash] Campaign data
      def get(advertiser_id, campaign_id)
        params = {
          advertiser_id: advertiser_id,
          campaign_ids: [campaign_id]
        }

        response = _http_get('get/', params)
        campaigns = response.dig('data', 'list') || []
        campaigns.first
      end

      # Update a campaign
      #
      # @param advertiser_id [String] Advertiser ID
      # @param campaign_id [String] Campaign ID
      # @param params [Hash] Campaign parameters to update
      # @return [Hash] Updated campaign data
      def update(advertiser_id, campaign_id, params = {})
        # Ensure required parameters are included
        params = params.merge(
          advertiser_id: advertiser_id,
          campaign_id: campaign_id
        )

        response = _http_post('update/', params)
        response['data']
      end

      # Update campaign status (enable/disable)
      #
      # @param advertiser_id [String] Advertiser ID
      # @param campaign_id [String] Campaign ID
      # @param status [String] New status ('ENABLE' or 'DISABLE')
      # @return [Hash] Result
      def update_status(advertiser_id, campaign_id, status)
        params = {
          advertiser_id: advertiser_id,
          campaign_ids: [campaign_id],
          operation_status: status
        }

        response = post('status/update/', params)
        response['data']
      end

      # Delete a campaign
      #
      # @param advertiser_id [String] Advertiser ID
      # @param campaign_id [String] Campaign ID
      # @return [Hash] Result
      def delete(advertiser_id, campaign_id)
        params = {
          advertiser_id: advertiser_id,
          campaign_ids: [campaign_id]
        }

        response = _http_post('delete/', params)
        response['data']
      end
    end
  end
end