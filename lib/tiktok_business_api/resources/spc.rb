# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Smart+ Campaigns resource for the TikTok Business API
    class Spc < CrudResource
      RESOURCE_NAME = "spc"

      def resource_name
        "campaign/spc"
      end

      def get(advertiser_id:, campaign_id:)
        list(advertiser_id: advertiser_id, campaign_ids: [campaign_id].to_json).first
      end

      def list(advertiser_id:, filtering: {}, page_size: nil, page: nil, **other_params, &block)
        super(filtering: filtering, page_size: page_size, page: page, **other_params.merge(advertiser_id: advertiser_id), &block)
      end

      def update(advertiser_id:, campaign_id:, **params)
        params = params.merge(
          advertiser_id: advertiser_id,
          campaign_id: campaign_id
        )

        response = _http_post(update_path, params)
        response["data"]
      end
    end
  end
end
