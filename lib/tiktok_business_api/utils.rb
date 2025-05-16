# frozen_string_literal: true

require "digest/md5"

module TiktokBusinessApi
  # Utility methods for TikTok Business API
  module Utils
    # Calculate MD5 hash of the file
    #
    # @param file [File, String] File object or file path
    # @return [String] MD5 hash
    def self.calculate_md5(file)
      if file.is_a?(String) && File.exist?(file)
        # File path was provided
        Digest::MD5.file(file).hexdigest
      elsif file.respond_to?(:path) && File.exist?(file.path)
        # File object with path
        Digest::MD5.file(file.path).hexdigest
      elsif file.respond_to?(:read)
        # IO-like object
        content = file.read
        file.rewind if file.respond_to?(:rewind) # Reset the file pointer
        Digest::MD5.hexdigest(content)
      else
        raise ArgumentError, "Unable to calculate MD5: invalid file object"
      end
    end

    # Detect content type based on file extension
    #
    # @param file [File, String] File object or file path
    # @return [String] MIME type
    def self.detect_content_type(file)
      file_path = if file.is_a?(String)
        file
      elsif file.respond_to?(:path)
        file.path
      else
        return "application/octet-stream" # Default if we can't determine
      end

      # Simple extension to MIME type mapping for common image formats
      case File.extname(file_path).downcase
      when ".jpg", ".jpeg"
        "image/jpeg"
      when ".png"
        "image/png"
      when ".gif"
        "image/gif"
      when ".bmp"
        "image/bmp"
      when ".webp"
        "image/webp"
      else
        "application/octet-stream"
      end
    end
  end
end
