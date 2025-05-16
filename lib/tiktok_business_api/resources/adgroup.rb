# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # AdGroup resource for the TikTok Business API
    class Adgroup < CrudResource
      RESOURCE_NAME = "adgroup"

      def get(advertiser_id:, adgroup_id:)
        list(advertiser_id: advertiser_id, filtering: {adgroup_ids: [adgroup_id]}).first
      end

      # Create a new ad group
      #
      # @param advertiser_id [String] Advertiser ID
      # @param params [Hash] Ad group parameters
      # @return [Hash] New ad group data
      def create(advertiser_id, params = {})
        # Ensure advertiser_id is included in the params
        params = params.merge(advertiser_id: advertiser_id)

        response = _http_post(create_path, params)
        response["data"]
      end

      def list(advertiser_id:, campaign_id: nil, filtering: {}, page_size: nil, page: nil, **other_params, &block)
        filtering[:campaign_ids] = [campaign_id] if campaign_id
        super(filtering: filtering, page_size: page_size, page: page, **other_params.merge(advertiser_id: advertiser_id), &block)
      end

      # Update an ad group
      #
      # @param advertiser_id [String] Advertiser ID
      # @param adgroup_id [String] Ad group ID
      # @param params [Hash] Ad group parameters to update
      # @return [Hash] Updated ad group data
      def update(advertiser_id, adgroup_id, params = {})
        params = params.merge(
          advertiser_id: advertiser_id,
          adgroup_id: adgroup_id
        )

        response = _http_post(update_path, params)
        response["data"]
      end

      # Update ad group status (enable/disable)
      #
      # @param advertiser_id [String] Advertiser ID
      # @param adgroup_id [String] Ad group ID
      # @param status [String] New status ('ENABLE' or 'DISABLE')
      # @return [Hash] Result
      def update_status(advertiser_id, adgroup_id, status)
        params = {
          advertiser_id: advertiser_id,
          adgroup_ids: [adgroup_id],
          operation_status: status
        }

        response = _http_post("status/update/", params)
        response["data"]
      end

      # Delete an ad group
      #
      # @param advertiser_id [String] Advertiser ID
      # @param adgroup_id [String] Ad group ID
      # @return [Hash] Result
      def delete(advertiser_id, adgroup_id)
        params = {
          advertiser_id: advertiser_id,
          adgroup_ids: [adgroup_id]
        }

        response = _http_post(delete_path, params)
        response["data"]
      end

      # Estimate audience size for an ad group
      #
      # @param advertiser_id [String] Advertiser ID
      # @param params [Hash] Targeting parameters for estimation
      # @return [Hash] Audience size estimation
      def estimate_audience_size(advertiser_id, params = {})
        params = params.merge(advertiser_id: advertiser_id)

        response = _http_post("audience_size/estimate/", params)
        response["data"]
      end
    end
  end
end
