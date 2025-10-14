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

      # Upload a video
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Upload options
      # @option options [String] :upload_type Upload type ('UPLOAD_BY_FILE', 'UPLOAD_BY_URL', 'UPLOAD_BY_FILE_ID', 'UPLOAD_BY_VIDEO_ID')
      # @option options [String] :file_name Video file name
      # @option options [File] :video_file Video file (required when upload_type is 'UPLOAD_BY_FILE')
      # @option options [String] :video_signature MD5 of video file (optional when upload_type is 'UPLOAD_BY_FILE', will be calculated if not provided)
      # @option options [String] :video_url Video URL (required when upload_type is 'UPLOAD_BY_URL')
      # @option options [String] :file_id File ID (required when upload_type is 'UPLOAD_BY_FILE_ID')
      # @option options [String] :video_id Video ID (required when upload_type is 'UPLOAD_BY_VIDEO_ID')
      # @option options [Boolean] :is_third_party Whether the video is third party
      # @option options [Boolean] :flaw_detect Whether to automatically detect issues in the video
      # @option options [Boolean] :auto_fix_enabled Whether to automatically fix detected issues
      # @option options [Boolean] :auto_bind_enabled Whether to automatically upload the fixed video to creative library
      # @return [Hash] Upload result with video ID
      def upload(advertiser_id:, **options)
        upload_type = options[:upload_type] || "UPLOAD_BY_FILE"

        params = {
          advertiser_id: advertiser_id,
          upload_type: upload_type
        }

        # Add file_name if provided
        params[:file_name] = options[:file_name] if options[:file_name]

        # Add Smart Fix parameters if provided
        params[:is_third_party] = options[:is_third_party] if options.key?(:is_third_party)
        params[:flaw_detect] = options[:flaw_detect] if options.key?(:flaw_detect)
        params[:auto_fix_enabled] = options[:auto_fix_enabled] if options.key?(:auto_fix_enabled)
        params[:auto_bind_enabled] = options[:auto_bind_enabled] if options.key?(:auto_bind_enabled)

        case upload_type
        when "UPLOAD_BY_FILE"
          raise ArgumentError, "video_file is required for UPLOAD_BY_FILE" unless options[:video_file]

          # Auto-calculate video signature if not provided
          unless options[:video_signature]
            options[:video_signature] = TiktokBusinessApi::Utils.calculate_md5(options[:video_file])
          end

          # Create a FilePart for multipart file upload
          params[:video_file] = Faraday::Multipart::FilePart.new(
            options[:video_file],
            TiktokBusinessApi::Utils.detect_content_type(options[:video_file])
          )
          params[:video_signature] = options[:video_signature]

          # For file uploads, we need to use multipart/form-data
          headers = {"Content-Type" => "multipart/form-data"}
          response = client.request(:post, "#{base_path}/upload/", params, headers)
        when "UPLOAD_BY_URL"
          raise ArgumentError, "video_url is required for UPLOAD_BY_URL" unless options[:video_url]

          params[:video_url] = options[:video_url]
          response = client.request(:post, "#{base_path}/upload/", params)
        when "UPLOAD_BY_FILE_ID"
          raise ArgumentError, "file_id is required for UPLOAD_BY_FILE_ID" unless options[:file_id]

          params[:file_id] = options[:file_id]
          response = client.request(:post, "#{base_path}/upload/", params)
        when "UPLOAD_BY_VIDEO_ID"
          raise ArgumentError, "video_id is required for UPLOAD_BY_VIDEO_ID" unless options[:video_id]

          params[:video_id] = options[:video_id]
          response = client.request(:post, "#{base_path}/upload/", params)
        else
          raise ArgumentError, "Invalid upload_type: #{upload_type}"
        end

        response["data"]
      end

      # Get video info by video IDs
      #
      # @param advertiser_id [String] Advertiser ID
      # @param video_ids [Array<String>] Video IDs (max size: 60)
      # @return [Array] List of video info
      def get_info(advertiser_id, video_ids)
        params = {
          advertiser_id: advertiser_id,
          video_ids: video_ids.to_json
        }
        response = client.request(:get, "#{base_path}/info/", params)
        response.dig("data", "list") || []
      end

      # Search for videos
      #
      # @param advertiser_id [String] Advertiser ID
      # @param options [Hash] Search options
      # @option options [Integer] :page Current page number (default: 1)
      # @option options [Integer] :page_size Page size (default: 20, range: 1-100)
      # @option options [Hash] :filtering Filters on the data
      # @option filtering [Array<String>] :video_ids A list of video IDs (max size: 100)
      # @option filtering [Array<String>] :material_ids A list of material IDs (max size: 20)
      # @option filtering [String] :video_name Video name for fuzzy search
      # @option filtering [Array<String>] :video_material_sources List of video material sources
      # @yield [video] Block to process each video
      # @yieldparam video [Hash] Video data from the response
      # @return [Hash, Array] Video list response or processed videos
      def search(advertiser_id:, **options, &block)
        # Set up default values
        page = options[:page] || 1
        page_size = options[:page_size] || 20

        params = {
          advertiser_id: advertiser_id,
          page: page,
          page_size: page_size
        }

        # Add filtering parameter if provided
        if options[:filtering]
          params[:filtering] = options[:filtering].to_json
        end

        response = client.request(:get, "#{base_path}/search/", params)
        video_list = response.dig("data", "list") || []

        if block_given?
          video_list.each(&block)
          response["data"]
        else
          video_list
        end
      end

      # Check if a video file name is already in use
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
