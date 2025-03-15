# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TiktokBusinessApi::Resources::Campaign do
  let(:client) { TiktokBusinessApi::Client.new(app_id: 'test_app_id', secret: 'test_secret') }
  let(:campaign) { described_class.new(client) }
  let(:advertiser_id) { '123456789' }
  let(:campaign_id) { '987654321' }

  describe '#create' do
    let(:params) do
      {
        campaign_name: 'Test Campaign',
        objective_type: 'TRAFFIC',
        budget_mode: 'BUDGET_MODE_TOTAL',
        budget: 1000
      }
    end

    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'campaign_id' => campaign_id,
          'campaign_name' => 'Test Campaign'
        }
      }
    end

    before do
      stub_request(:post, "#{client.config.api_base_url}v1.3/campaign/create/")
        .with(
          body: hash_including(params.merge(advertiser_id: advertiser_id)),
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response.to_json)
    end

    it 'creates a campaign with the specified parameters' do
      result = campaign.create(advertiser_id, params)
      expect(result).to eq(response['data'])
    end
  end

  describe '#list' do
    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'list' => [
            { 'campaign_id' => '111', 'campaign_name' => 'Campaign 1' },
            { 'campaign_id' => '222', 'campaign_name' => 'Campaign 2' }
          ],
          'page_info' => {
            'total_number' => 2,
            'page' => 1,
            'page_size' => 10,
            'total_page' => 1
          }
        }
      }
    end

    before do
      stub_request(:get, "#{client.config.api_base_url}v1.3/campaign/get/")
        .with(query: hash_including(advertiser_id: advertiser_id))
        .to_return(status: 200, body: response.to_json)
    end

    it 'returns a list of campaigns' do
      result = campaign.list(advertiser_id)
      expect(result).to eq(response['data'])
    end
  end

  describe '#get' do
    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'list' => [
            { 'campaign_id' => campaign_id, 'campaign_name' => 'Test Campaign' }
          ]
        }
      }
    end

    before do
      stub_request(:get, "#{client.config.api_base_url}v1.3/campaign/get/")
        .with(query: hash_including(advertiser_id: advertiser_id, campaign_ids: [campaign_id]))
        .to_return(status: 200, body: response.to_json)
    end

    it 'returns a specific campaign' do
      result = campaign.get(advertiser_id, campaign_id)
      expect(result).to eq(response['data']['list'].first)
    end
  end

  describe '#update' do
    let(:update_params) do
      {
        campaign_name: 'Updated Campaign'
      }
    end

    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'campaign_id' => campaign_id,
          'campaign_name' => 'Updated Campaign'
        }
      }
    end

    before do
      stub_request(:post, "#{client.config.api_base_url}v1.3/campaign/update/")
        .with(
          body: hash_including(
            advertiser_id: advertiser_id,
            campaign_id: campaign_id,
            campaign_name: 'Updated Campaign'
          ),
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response.to_json)
    end

    it 'updates a campaign with the specified parameters' do
      result = campaign.update(advertiser_id, campaign_id, update_params)
      expect(result).to eq(response['data'])
    end
  end

  describe '#update_status' do
    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'campaign_ids' => [campaign_id]
        }
      }
    end

    before do
      stub_request(:post, "#{client.config.api_base_url}v1.3/campaign/status/update/")
        .with(
          body: hash_including(
            advertiser_id: advertiser_id,
            campaign_ids: [campaign_id],
            operation_status: 'DISABLE'
          ),
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response.to_json)
    end

    it 'updates the campaign status' do
      result = campaign.update_status(advertiser_id, campaign_id, 'DISABLE')
      expect(result).to eq(response['data'])
    end
  end

  describe '#delete' do
    let(:response) do
      {
        'code' => 0,
        'message' => 'OK',
        'data' => {
          'campaign_ids' => [campaign_id]
        }
      }
    end

    before do
      stub_request(:post, "#{client.config.api_base_url}v1.3/campaign/delete/")
        .with(
          body: hash_including(
            advertiser_id: advertiser_id,
            campaign_ids: [campaign_id]
          ),
          headers: { 'Content-Type' => 'application/json' }
        )
        .to_return(status: 200, body: response.to_json)
    end

    it 'deletes a campaign' do
      result = campaign.delete(advertiser_id, campaign_id)
      expect(result).to eq(response['data'])
    end
  end
end