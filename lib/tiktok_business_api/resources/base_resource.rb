# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Base class for all API resources
    class BaseResource
      # @return [TiktokBusinessApi::Client] Client instance
      attr_reader :client

      # Initialize a new resource
      #
      # @param client [TiktokBusinessApi::Client] Client instance
      def initialize(client)
        @client = client
      end

      # Get the resource name (used for endpoint paths)
      #
      # @return [String] Resource name
      def resource_name
        self.class.name.split('::').last.downcase
      end

      # Get the API version
      #
      # @return [String] API version
      def api_version
        'v1.3'
      end

      # Get the base path for this resource
      #
      # @return [String] Base path
      def base_path
        "#{api_version}/#{resource_name}/"
      end

      # Make a GET request to the resource
      #
      # @param path [String] Path relative to the resource base path
      # @param params [Hash] Query parameters
      # @param headers [Hash] Custom headers
      # @return [Hash] Response data
      def _http_get(path, params = {}, headers = {})
        full_path = File.join(base_path, path)
        client.request(:get, full_path, params, headers)
      end

      # Make a POST request to the resource
      #
      # @param path [String] Path relative to the resource base path
      # @param params [Hash] Body parameters
      # @param headers [Hash] Custom headers
      # @return [Hash] Response data
      def _http_post(path, params = {}, headers = {})
        full_path = File.join(base_path, path)
        client.request(:post, full_path, params, headers)
      end

      # Handle pagination for list endpoints
      #
      # @param path [String] Path relative to the resource base path
      # @param params [Hash] Query parameters
      # @param headers [Hash] Custom headers
      # @param data_key [String] Key in the response that contains the data array
      # @yield [item] Block to process each item
      # @yieldparam item [Hash] Item from the response
      # @return [Array] All items if no block is given
      def paginate(path, params = {}, headers = {}, data_key = 'data')
        items = []
        page = 1
        page_size = params[:page_size] || 10
        has_more = true

        while has_more
          params[:page] = page
          params[:page_size] = page_size

          response = get(path, params, headers)

          # Extract data from the response
          current_items = response.dig('data', data_key) || []

          if block_given?
            current_items.each { |item| yield(item) }
          else
            items.concat(current_items)
          end

          # Check if there are more pages
          page_info = response.dig('data', 'page_info') || {}
          has_more = page_info['has_more'] == true
          page += 1
        end

        block_given? ? nil : items
      end
    end
  end
end