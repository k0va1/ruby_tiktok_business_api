# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Base CRUD class for all API resources
    class CrudResource < BaseResource
      # Default path for create operations
      def create_path
        "create/"
      end

      # Default path for read/list operations
      def list_path
        "get/"
      end

      # Default path for update operations
      def update_path
        "update/"
      end

      # Default path for delete operations
      def delete_path
        "delete/"
      end

      # Default path for status updates
      def status_update_path
        "status/update/"
      end

      def resource_name
        self.class::RESOURCE_NAME
      end

      # Default ID parameter name
      def id_param_name
        "#{resource_name}_id"
      end

      # Default IDs parameter name for bulk operations
      def ids_param_name
        "#{resource_name}_ids"
      end

      # Create a new resource
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param params [Hash] Resource parameters
      # @param owner_param_name [String] Parameter name for the owner ID
      # @return [Hash] New resource data
      def create(owner_id, params = {}, owner_param_name = "advertiser_id")
        params = params.merge(owner_param_name => owner_id)
        response = _http_post(create_path, params)
        response["data"]
      end

      def list(filtering: {}, page_size: nil, page: nil, **other_params, &block)
        # Build request paramss
        request_params = other_params.merge(filtering: filtering.to_json)

        page_size ||= 100
        page ||= 1
        request_params[:page_size] = [page_size, 100].min # Most APIs limit page size
        request_params[:page] = page

        # Make the request
        response = _http_get(list_path, request_params)

        # If a block is given, yield each item
        if block_given?
          items = response.dig("data", "list") || []
          items.each(&block)

          # Return the response for method chaining
          response
        else
          # Just return the data otherwise
          response["data"]["list"]
        end
      end

      # List all resources with automatic pagination
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param filtering [Hash] Filtering parameters
      # @param params [Hash] Additional parameters
      # @param owner_param_name [String] Parameter name for the owner ID
      # @param list_key [String] Key in the response that contains the data array
      # @yield [resource] Block to process each resource
      # @yieldparam resource [Hash] Resource from the response
      # @return [Array] All resources if no block is given
      def list_all(owner_id, params = {}, owner_param_name = "advertiser_id", list_key = "list", filtering: {}, &block)
        items = []
        page = 1
        page_size = params[:page_size] || 10
        has_more = true

        # Ensure owner_id is included in the params
        request_params = params.merge(owner_param_name => owner_id)
        request_params[:filtering] = filtering.to_json unless filtering.empty?

        while has_more
          request_params[:page] = page
          request_params[:page_size] = page_size

          response = _http_get(list_path, request_params)

          # Extract data from the response
          current_items = response.dig("data", list_key) || []

          if block_given?
            current_items.each(&block)
          else
            items.concat(current_items)
          end

          # Check if there are more pages
          page_info = response.dig("data", "page_info") || {}
          total_number = page_info["total_number"] || 0
          total_fetched = page * page_size

          has_more = page_info["has_more"] == true ||
            (total_number > 0 && total_fetched < total_number)
          page += 1

          # Break if we've reached the end or there's an empty result
          break if current_items.empty?
        end

        block_given? ? nil : items
      end

      # Get a resource by ID
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param resource_id [String] Resource ID
      # @param owner_param_name [String] Parameter name for the owner ID
      # @return [Hash] Resource data
      def get(owner_id, resource_id, owner_param_name = "advertiser_id")
        params = {
          owner_param_name => owner_id,
          ids_param_name => [resource_id]
        }

        response = _http_get(list_path, params)
        items = response.dig("data", "list") || []
        items.first
      end

      # Update a resource
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param resource_id [String] Resource ID
      # @param params [Hash] Resource parameters to update
      # @param owner_param_name [String] Parameter name for the owner ID
      # @return [Hash] Updated resource data
      def update(owner_id, resource_id, params = {}, owner_param_name = "advertiser_id")
        # Ensure required parameters are included
        params = params.merge(
          owner_param_name => owner_id,
          id_param_name => resource_id
        )

        response = _http_post(update_path, params)
        response["data"]
      end

      # Update resource status
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param resource_id [String] Resource ID
      # @param status [String] New status
      # @param owner_param_name [String] Parameter name for the owner ID
      # @return [Hash] Result
      def update_status(owner_id, resource_id, status, owner_param_name = "advertiser_id")
        params = {
          owner_param_name => owner_id,
          ids_param_name => [resource_id],
          "operation_status" => status
        }

        response = _http_post(status_update_path, params)
        response["data"]
      end

      # Delete a resource
      #
      # @param owner_id [String] ID of the resource owner (e.g., advertiser_id)
      # @param resource_id [String] Resource ID
      # @param owner_param_name [String] Parameter name for the owner ID
      # @return [Hash] Result
      def delete(owner_id, resource_id, owner_param_name = "advertiser_id")
        params = {
          owner_param_name => owner_id,
          ids_param_name => [resource_id]
        }

        response = _http_post(delete_path, params)
        response["data"]
      end
    end
  end
end
