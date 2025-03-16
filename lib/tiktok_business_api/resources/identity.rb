# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Identity resource for the TikTok Business API
    class Identity < BaseResource
      RESOURCE_NAME = 'identity'

      # Get a list of identities
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Additional options for the request
      # @option options [String] :identity_type Identity type. Enum values: CUSTOMIZED_USER, AUTH_CODE, TT_USER, BC_AUTH_TT
      # @option options [String] :identity_authorized_bc_id ID of the Business Center (required when identity_type is BC_AUTH_TT)
      # @option options [Hash] :filtering Filtering conditions (valid only for CUSTOMIZED_USER or when identity_type not specified)
      # @option options [Integer] :page Page number
      # @option options [Integer] :page_size Number of results per page
      # @return [Hash] Response with list of identities and pagination info
      def list(advertiser_id:, **options)
        params = {
          advertiser_id: advertiser_id
        }

        # Add optional parameters if provided
        params[:identity_type] = options[:identity_type] if options[:identity_type]
        params[:identity_authorized_bc_id] = options[:identity_authorized_bc_id] if options[:identity_authorized_bc_id]
        params[:filtering] = options[:filtering].to_json if options[:filtering]
        params[:page] = options[:page] if options[:page]
        params[:page_size] = options[:page_size] if options[:page_size]

        response = client.request(:get, "#{base_path}get/", params)

        if block_given? && response['data']['identity_list']
          response['data']['identity_list'].each { |identity| yield(identity) }
          response['data']
        else
          response['data']
        end
      end

      # Get information about a specific identity
      #
      # @param advertiser_id [String] Advertiser ID
      # @param identity_id [String] Identity ID
      # @param identity_type [String] Identity type. Enum values: CUSTOMIZED_USER, AUTH_CODE, TT_USER, BC_AUTH_TT
      # @param identity_authorized_bc_id [String] ID of the Business Center (required when identity_type is BC_AUTH_TT)
      # @return [Hash] Identity information
      def get_info(advertiser_id:, identity_id:, identity_type:, identity_authorized_bc_id: nil)
        params = {
          advertiser_id: advertiser_id,
          identity_id: identity_id,
          identity_type: identity_type
        }

        # Add Business Center ID if provided (required for BC_AUTH_TT)
        params[:identity_authorized_bc_id] = identity_authorized_bc_id if identity_authorized_bc_id

        response = client.request(:get, "#{base_path}info/", params)
        response['data']['identity_info']
      end

      # Create a new Custom User identity
      #
      # @param advertiser_id [String] Advertiser ID
      # @param display_name [String] Display name (max 100 characters)
      # @param image_uri [String] The ID of the avatar image (optional)
      # @return [Hash] Response containing the new identity ID
      def create(advertiser_id:, display_name:, image_uri: nil)
        params = {
          advertiser_id: advertiser_id,
          display_name: display_name
        }

        # Add image URI if provided
        params[:image_uri] = image_uri if image_uri

        response = client.request(:post, "#{base_path}create/", params)
        response['data']
      end

      # List all identities with automatic pagination
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Additional options for the request
      # @yield [identity] Block to process each identity
      # @yieldparam identity [Hash] Identity from the response
      # @return [Array, nil] All identities if no block is given, nil otherwise
      def list_all(advertiser_id:, **options, &block)
        page = options[:page] || 1
        page_size = options[:page_size] || 100
        all_identities = []
        has_more = true

        while has_more
          current_options = options.merge(page: page, page_size: page_size)
          response = list(advertiser_id: advertiser_id, **current_options)

          identities = response['identity_list'] || []

          if block_given?
            identities.each { |identity| yield(identity) }
          else
            all_identities.concat(identities)
          end

          # Check pagination info
          page_info = response['page_info'] || {}
          current_page = page_info['page'].to_i
          total_pages = page_info['total_page'].to_i

          has_more = current_page < total_pages
          page += 1

          # Break if empty result or no more pages
          break if identities.empty? || !has_more
        end

        block_given? ? nil : all_identities
      end
    end
  end
end