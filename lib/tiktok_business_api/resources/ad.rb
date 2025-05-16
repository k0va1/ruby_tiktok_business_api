# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Ad resource for the TikTok Business API
    class Ad < CrudResource
      RESOURCE_NAME = "ad"

      def get(advertiser_id:, ad_id:)
        list(advertiser_id: advertiser_id, filtering: {ad_ids: [ad_id]}).first
      end

      # Create a new ad
      #
      # @param advertiser_id [String] Advertiser ID
      # @param adgroup_id [String] Ad group ID
      # @param creatives [Array<Hash>] Array of creative objects
      # @return [Hash] New ad data with created ad IDs
      def create(advertiser_id:, adgroup_id:, creatives:)
        params = {
          advertiser_id: advertiser_id,
          adgroup_id: adgroup_id,
          creatives: creatives
        }

        response = _http_post(create_path, params)
        response["data"]
      end

      def list(advertiser_id:, campaign_id: nil, adgroup_id: nil, filtering: {}, page_size: nil, page: nil,
        **other_params, &block)
        filtering[:campaign_ids] = [campaign_id] if campaign_id
        filtering[:adgroup_ids] = [adgroup_id] if adgroup_id
        super(filtering: filtering, page_size: page_size, page: page, **other_params.merge(advertiser_id: advertiser_id), &block)
      end

      # Update an ad
      #
      # @param advertiser_id [String] Advertiser ID
      # @param ad_id [String] Ad ID
      # @param params [Hash] Ad parameters to update
      # @return [Hash] Updated ad data
      def update(advertiser_id:, ad_id:, **params)
        params = params.merge(
          advertiser_id: advertiser_id,
          ad_id: ad_id
        )

        response = _http_post(update_path, params)
        response["data"]
      end

      # Update ad status (enable/disable)
      #
      # @param advertiser_id [String] Advertiser ID
      # @param ad_id [String] Ad ID
      # @param status [String] New status ('ENABLE' or 'DISABLE')
      # @return [Hash] Result
      def update_status(advertiser_id:, ad_id:, status:)
        params = {
          advertiser_id: advertiser_id,
          ad_ids: [ad_id],
          operation_status: status
        }

        response = _http_post("status/update/", params)
        response["data"]
      end

      # Delete an ad
      #
      # @param advertiser_id [String] Advertiser ID
      # @param ad_id [String] Ad ID
      # @return [Hash] Result
      def delete(advertiser_id:, ad_id:)
        params = {
          advertiser_id: advertiser_id,
          ad_ids: [ad_id]
        }

        response = _http_post(delete_path, params)
        response["data"]
      end

      # Create Smart Creative ads
      #
      # @param advertiser_id [String] Advertiser ID
      # @param adgroup_id [String] Ad group ID
      # @param creatives [Array<Hash>] Array of creative objects
      # @return [Hash] New Smart Creative ad data
      def create_aco(advertiser_id:, adgroup_id:, creatives:)
        params = {
          advertiser_id: advertiser_id,
          adgroup_id: adgroup_id,
          creatives: creatives
        }

        response = _http_post("aco/create/", params)
        response["data"]
      end
    end
  end
end
