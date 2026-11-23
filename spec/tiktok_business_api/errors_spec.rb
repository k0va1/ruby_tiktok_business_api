# frozen_string_literal: true

require "spec_helper"

RSpec.describe TiktokBusinessApi::ErrorFactory do
  let(:client) { TiktokBusinessApi::Client.new(app_id: "test_app_id", secret: "test_secret") }
  let(:url) { "#{client.config.api_base_url}error/path" }

  def error_for(status:, body:)
    stub_request(:get, url).to_return(status: status, body: body.is_a?(String) ? body : body.to_json)
    client.request(:get, "error/path")
  rescue TiktokBusinessApi::Error => e
    e
  end

  context "when TikTok answers HTTP 200 with a non-zero code" do
    it "raises AuthorizationError for a missing permission (40001)" do
      error = error_for(status: 200, body: {
        "code" => 40_001,
        "message" => "advertiser does not grant you /comment/list/:GET permission",
        "request_id" => "20261120142336ABC"
      })

      expect(error).to be_a(TiktokBusinessApi::AuthorizationError)
      expect(error.message).to eq("advertiser does not grant you /comment/list/:GET permission")
      expect(error.code).to eq(40_001)
      expect(error.status_code).to eq(200)
      expect(error.request_id).to eq("20261120142336ABC")
    end

    it "raises RateLimitError for too frequent requests (40100)" do
      error = error_for(status: 200, body: {"code" => 40_100, "message" => "Too many requests."})

      expect(error).to be_a(TiktokBusinessApi::RateLimitError)
      expect(error.code).to eq(40_100)
    end

    it "raises AuthenticationError for a rejected access token (40105)" do
      error = error_for(status: 200, body: {"code" => 40_105, "message" => "Access token is incorrect or has been revoked."})

      expect(error).to be_a(TiktokBusinessApi::AuthenticationError)
    end

    it "raises ApiError for a server-side failure (5xxxx)" do
      error = error_for(status: 200, body: {"code" => 50_000, "message" => "Internal timeout, Please try again later."})

      expect(error).to be_a(TiktokBusinessApi::ApiError)
      expect(error.code).to eq(50_000)
    end

    it "raises the base Error for a code it does not classify" do
      error = error_for(status: 200, body: {"code" => 40_002, "message" => "Error: Submission failed. Try again."})

      expect(error.class).to eq(TiktokBusinessApi::Error)
      expect(error.code).to eq(40_002)
    end

    it "reads a code sent as a string" do
      error = error_for(status: 200, body: {"code" => "40100", "message" => "Too many requests."})

      expect(error).to be_a(TiktokBusinessApi::RateLimitError)
      expect(error.code).to eq(40_100)
    end
  end

  context "when the HTTP status is an error" do
    it "lets the TikTok code win over the status" do
      error = error_for(status: 400, body: {"code" => 40_100, "message" => "Too many requests."})

      expect(error).to be_a(TiktokBusinessApi::RateLimitError)
    end

    it "falls back to the status when the code does not tell" do
      expect(error_for(status: 400, body: {"code" => 40_002, "message" => "Bad Request"})).to be_a(TiktokBusinessApi::InvalidRequestError)
      expect(error_for(status: 401, body: {"message" => "Unauthorized"})).to be_a(TiktokBusinessApi::AuthenticationError)
      expect(error_for(status: 403, body: {"message" => "Forbidden"})).to be_a(TiktokBusinessApi::AuthorizationError)
      expect(error_for(status: 429, body: {"message" => "Slow down"})).to be_a(TiktokBusinessApi::RateLimitError)
      expect(error_for(status: 503, body: {"message" => "Unavailable"})).to be_a(TiktokBusinessApi::ApiError)
    end

    it "has no code or request id when the body is not JSON" do
      error = error_for(status: 502, body: "<html>Bad Gateway</html>")

      expect(error).to be_a(TiktokBusinessApi::ApiError)
      expect(error.message).to eq("HTTP 502")
      expect(error.code).to be_nil
      expect(error.request_id).to be_nil
    end
  end
end
