# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Campaign resource for the TikTok Business API
    class Campaign < CrudResource
      RESOURCE_NAME = "campaign"

      def get(advertiser_id:, campaign_id:)
        list(advertiser_id: advertiser_id, filtering: {campaign_ids: [campaign_id]}).first
      end

      def list(advertiser_id:, filtering: {}, page_size: nil, page: nil, **other_params, &block)
        super(filtering: filtering, page_size: page_size, page: page, **other_params.merge(advertiser_id: advertiser_id), &block)
      end
    end
  end
end
