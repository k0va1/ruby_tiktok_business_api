# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Reporting resource for the TikTok Business API
    class Reporting < BaseResource
      # Get the resource name (used for endpoint paths)
      #
      # @return [String] Resource name
      def resource_name
        "report/integrated"
      end

      def get_sync_report(**params)
        response = client.request(:get, "#{base_path}/get", params)
        response.dig("data", "list") || []
      end
    end
  end
end
