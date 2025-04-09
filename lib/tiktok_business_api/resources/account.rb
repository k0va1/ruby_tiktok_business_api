# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    class Account < CrudResource
      RESOURCE_NAME = 'advertiser'

      def list(app_id:, secret:, &block)
        params = {
          app_id: app_id,
          secret: secret
        }

        response = client.request(:get, "/v1.3/oauth2/advertiser/get/", params)
        if block_given?
          items = response.dig('data', 'list') || []
          items.each { |item| yield(item) }

          response
        else
          response['data']['list']
        end
      end

      def details(advertiser_ids:, fields: [])
        params = {
          advertiser_ids: advertiser_ids,
          fields: fields
        }

        response = client.request(:get, "#{base_path}info", params)
        response.dig('data', 'list') || []
      end
    end
  end
end
