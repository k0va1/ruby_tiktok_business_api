# frozen_string_literal: true

require "spec_helper"

RSpec.describe TiktokBusinessApi::Client do
  let(:app_id) { "test_app_id" }
  let(:secret) { "test_secret" }
  let(:client) { TiktokBusinessApi::Client.new(app_id: app_id, secret: secret) }

  describe "#initialize" do
    it "sets up configuration with provided options" do
      expect(client.config.app_id).to eq(app_id)
      expect(client.config.secret).to eq(secret)
    end

    it "uses default configuration values" do
      expect(client.config.api_base_url).to eq("https://business-api.tiktok.com/open_api/")
      expect(client.config.debug).to be false
    end
  end

  describe "#resource" do
    it "returns a campaign resource" do
      resource = client.resource(:campaign)
      expect(resource).to be_a(TiktokBusinessApi::Resources::Campaign)
    end

    it "caches resources" do
      resource1 = client.resource(:campaign)
      resource2 = client.resource(:campaign)
      expect(resource1).to be(resource2)
    end
  end

  describe "#campaigns" do
    it "returns a campaign resource" do
      expect(client.campaigns).to be_a(TiktokBusinessApi::Resources::Campaign)
    end
  end

  describe "#request" do
    let(:success_response) do
      {
        "code" => 0,
        "message" => "OK",
        "data" => {"test" => "data"}
      }
    end

    before do
      stub_request(:get, "#{client.config.api_base_url}test/path")
        .with(query: {param: "value"})
        .to_return(status: 200, body: success_response.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "makes a request to the TikTok API" do
      response = client.request(:get, "test/path", {param: "value"})
      expect(response).to eq(success_response)
    end

    context "when the API returns an error" do
      before do
        stub_request(:get, "#{client.config.api_base_url}error/path")
          .to_return(status: 400, body: {"code" => 40_000, "message" => "Bad Request"}.to_json)
      end

      it "raises an error" do
        expect { client.request(:get, "error/path") }.to raise_error(TiktokBusinessApi::InvalidRequestError)
      end
    end
  end
end
