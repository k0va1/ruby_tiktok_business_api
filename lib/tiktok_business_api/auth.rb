# frozen_string_literal: true

module TiktokBusinessApi
  # Handles authentication with the TikTok Business API
  class Auth
    # @return [TiktokBusinessApi::Client] Client instance
    attr_reader :client

    # Initialize the Auth handler
    #
    # @param client [TiktokBusinessApi::Client] Client instance
    def initialize(client)
      @client = client
    end

    # Generate an access token using an authorization code
    #
    # @param auth_code [String] Authorization code from TikTok
    # @param redirect_uri [String] Redirect URI used in the authorization request
    # @return [Hash] Access token response
    def generate_access_token(auth_code, redirect_uri)
      params = {
        app_id: client.config.app_id,
        secret: client.config.secret,
        auth_code: auth_code,
        grant_type: "auth_code"
      }

      # Add redirect_uri if provided
      params[:redirect_uri] = redirect_uri if redirect_uri

      response = client.request(:post, "v1.3/oauth2/access_token/", params)

      # Store the access token in the client config
      if response["data"] && response["data"]["access_token"]
        client.config.access_token = response["data"]["access_token"]
      end

      response
    end

    # Refresh an access token (for TikTok account access tokens)
    #
    # @param refresh_token [String] Refresh token
    # @return [Hash] New access token response
    def refresh_access_token(refresh_token)
      params = {
        app_id: client.config.app_id,
        secret: client.config.secret,
        refresh_token: refresh_token,
        grant_type: "refresh_token"
      }

      response = client.request(:post, "v1.3/tt_user/oauth2/refresh_token/", params)

      # Update the access token in the client config
      if response["data"] && response["data"]["access_token"]
        client.config.access_token = response["data"]["access_token"]
      end

      response
    end

    # Revoke an access token
    #
    # @param token [String] Access token to revoke (defaults to the current access token)
    # @return [Hash] Response
    def revoke_access_token(token = nil)
      token ||= client.config.access_token

      params = {
        app_id: client.config.app_id,
        secret: client.config.secret,
        access_token: token
      }

      response = client.request(:post, "v1.3/oauth2/revoke_token/", params)

      # Clear the access token if it was revoked
      client.config.access_token = nil if response["code"] == 0

      response
    end

    # Get a list of authorized advertiser accounts
    #
    # @param app_id [String] App ID (defaults to the configured app_id)
    # @param secret [String] App secret (defaults to the configured secret)
    # @param access_token [String] Access token (defaults to the configured access_token)
    # @return [Hash] List of authorized advertisers
    def get_authorized_advertisers(_app_id = nil, _secret = nil, access_token = nil)
      params = {}

      # Use provided values or fallback to client config
      headers = {}
      headers["Access-Token"] = access_token || client.config.access_token if access_token || client.config.access_token

      client.request(:get, "v1.3/oauth2/advertiser/get/", params, headers)
    end

    # Generate authorization URL for TikTok Business API
    #
    # @param redirect_uri [String] Redirect URI where the authorization code will be sent
    # @param state [String] Optional state parameter for security
    # @param scope [Array<String>] Optional array of permission scopes
    # @return [String] Authorization URL
    def authorization_url(redirect_uri, state = nil, scope = nil)
      params = {
        app_id: client.config.app_id,
        redirect_uri: redirect_uri
      }

      params[:state] = state if state
      params[:scope] = scope.join(",") if scope && !scope.empty?

      query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join("&")
      "https://ads.tiktok.com/marketing_api/auth?#{query}"
    end
  end
end
