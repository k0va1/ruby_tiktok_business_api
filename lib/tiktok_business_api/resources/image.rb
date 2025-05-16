# frozen_string_literal: true

module TiktokBusinessApi
  module Resources
    # Image resource for the TikTok Business API
    class Image < BaseResource
      # Get the resource name (used for endpoint paths)
      #
      # @return [String] Resource name
      def resource_name
        "file/image/ad"
      end

      # Upload an image
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Upload options
      # @option options [String] :upload_type Upload type ('UPLOAD_BY_FILE', 'UPLOAD_BY_URL', 'UPLOAD_BY_FILE_ID')
      # @option options [String] :file_name Image file name
      # @option options [File] :image_file Image file (required when upload_type is 'UPLOAD_BY_FILE')
      # @option options [String] :image_signature MD5 of image file (optional when upload_type is 'UPLOAD_BY_FILE', will be calculated if not provided)
      # @option options [String] :image_url Image URL (required when upload_type is 'UPLOAD_BY_URL')
      # @option options [String] :file_id File ID (required when upload_type is 'UPLOAD_BY_FILE_ID')
      # @return [Hash] Upload result with image ID
      def upload(advertiser_id:, **options)
        upload_type = options[:upload_type] || "UPLOAD_BY_FILE"

        params = {
          advertiser_id: advertiser_id,
          upload_type: upload_type
        }

        # Add file_name if provided
        params[:file_name] = options[:file_name] if options[:file_name]

        case upload_type
        when "UPLOAD_BY_FILE"
          raise ArgumentError, "image_file is required for UPLOAD_BY_FILE" unless options[:image_file]

          # Auto-calculate image signature if not provided
          unless options[:image_signature]
            options[:image_signature] = TiktokBusinessApi::Utils.calculate_md5(options[:image_file])
          end

          # Create a FilePart for multipart file upload
          params[:image_file] = Faraday::Multipart::FilePart.new(
            options[:image_file],
            TiktokBusinessApi::Utils.detect_content_type(options[:image_file])
          )
          params[:image_signature] = options[:image_signature]

          # For file uploads, we need to use multipart/form-data
          headers = {"Content-Type" => "multipart/form-data"}
          response = client.request(:post, "#{base_path}/upload/", params, headers)
        when "UPLOAD_BY_URL"
          raise ArgumentError, "image_url is required for UPLOAD_BY_URL" unless options[:image_url]

          params[:image_url] = options[:image_url]
          response = client.request(:post, "#{base_path}/upload/", params)
        when "UPLOAD_BY_FILE_ID"
          raise ArgumentError, "file_id is required for UPLOAD_BY_FILE_ID" unless options[:file_id]

          params[:file_id] = options[:file_id]
          response = client.request(:post, "#{base_path}/upload/", params)
        else
          raise ArgumentError, "Invalid upload_type: #{upload_type}"
        end

        response["data"]
      end

      # Get image info by image ID
      #
      # @param advertiser_id [String] Advertiser ID
      # @param image_id [String] Image ID
      # @return [Hash] Image info
      def get_info(advertiser_id, image_id)
        params = {
          advertiser_id: advertiser_id,
          image_ids: [image_id]
        }

        response = client.request(:get, "#{base_path}/info/", params)
        images = response.dig("data", "list") || []
        images.first
      end

      # Search for images
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Search options
      # @option options [Integer] :page Current page number (default: 1)
      # @option options [Integer] :page_size Page size (default: 20)
      # @option options [String] :image_ids Image IDs, comma-separated
      # @option options [String] :material_ids Material IDs, comma-separated
      # @option options [Integer] :width Image width
      # @option options [Integer] :height Image height
      # @option options [String] :signature Image MD5 hash
      # @option options [Integer] :start_time Start time, in seconds
      # @option options [Integer] :end_time End time, in seconds
      # @option options [Boolean] :displayable Whether image can be displayed
      # @yield [image] Block to process each image
      # @yieldparam image [Hash] Image data from the response
      # @return [Hash, Array] Image list response or processed images
      def search(advertiser_id:, **options, &block)
        # Set up default values
        page = options[:page] || 1
        page_size = options[:page_size] || 20

        params = {
          advertiser_id: advertiser_id,
          page: page,
          page_size: page_size
        }

        # Add optional parameters if provided
        search_fields = %i[image_ids material_ids width height signature
          start_time end_time displayable]

        search_fields.each do |field|
          params[field] = options[field] if options.key?(field)
        end

        response = client.request(:get, "#{base_path}/search/", params)
        image_list = response.dig("data", "list") || []

        if block_given?
          image_list.each(&block)
          response["data"]
        else
          image_list
        end
      end

      # Check if an image file name is already in use
      #
      # @param advertiser_id [String] Advertiser ID
      # @param file_names [Array<String>] List of file names to check
      # @return [Hash] Result with available and unavailable file names
      def check_name(advertiser_id, file_names)
        params = {
          advertiser_id: advertiser_id,
          file_names: file_names
        }

        response = client.request(:post, "file/name/check/", params)
        response["data"]
      end
    end
  end
end
