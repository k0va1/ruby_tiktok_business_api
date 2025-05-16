# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Video resource for the TikTok Business API
    class Video < BaseResource
      # Get the resource name (used for endpoint paths)
      #
      # @return [String] Resource name
      def resource_name
        "file/video/ad"
      end

      # Get video info by video IDs
      #
      # @param advertiser_id [String] Advertiser ID
      # @param video_ids [String] Video IDs
      # @return [Hash] Video info
      def get_info(advertiser_id, video_ids)
        params = {
          advertiser_id: advertiser_id,
          video_ids: video_ids.to_json
        }
        response = client.request(:get, "#{base_path}info/", params)
        response.dig("data", "list") || []
      end
    end
  end
end
