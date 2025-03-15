# frozen_string_literal: true
# Example of basic usage of the TikTok Business API gem

require 'tiktok_business_api'
require 'logger'

# Configure the client
TiktokBusinessApi.configure do |config|
  config.app_id = 'YOUR_APP_ID'
  config.secret = 'YOUR_APP_SECRET'
  config.debug = true
  config.logger = Logger.new(STDOUT)
end

# Initialize a client
client = TiktokBusinessApi.client

# Step 1: Generate an authorization URL for the user to grant access
auth_url = client.auth.authorization_url('https://your-redirect-url.com/callback')
puts "Open this URL in your browser to authorize the app:"
puts auth_url

# Step 2: After authorization, you'll receive an auth code in your callback
puts "Enter the authorization code from the callback URL:"
auth_code = gets.chomp

# Step 3: Generate an access token using the auth code
response = client.auth.generate_access_token(auth_code, 'https://your-redirect-url.com/callback')

if response['code'] == 0
  access_token = response['data']['access_token']
  puts "Successfully obtained access token: #{access_token}"
  
  # The access token is automatically stored in the client config
  
  # Step 4: Get authorized advertisers
  advertisers = client.auth.get_authorized_advertisers
  
  puts "Authorized advertisers:"
  advertisers['data']['list'].each do |advertiser|
    puts "- #{advertiser['advertiser_name']} (ID: #{advertiser['advertiser_id']})"
  end
  
  # Choose an advertiser to work with
  advertiser_id = advertisers['data']['list'].first['advertiser_id']
  
  # Step 5: Create a campaign
  campaign_params = {
    campaign_name: "My Test Campaign #{Time.now.to_i}",
    objective_type: 'TRAFFIC',
    budget_mode: 'BUDGET_MODE_TOTAL',
    budget: 1000
  }
  
  begin
    campaign = client.campaigns.create(advertiser_id, campaign_params)
    puts "Created campaign: #{campaign['campaign_name']} (ID: #{campaign['campaign_id']})"
    
    # Step 6: Get all campaigns for the advertiser
    puts "\nListing all campaigns:"
    client.campaigns.list_all(advertiser_id) do |camp|
      puts "- #{camp['campaign_name']} (ID: #{camp['campaign_id']}, Status: #{camp['operation_status']})"
    end
    
    # Step 7: Update the campaign
    update_params = {
      campaign_name: "Updated Campaign #{Time.now.to_i}"
    }
    
    updated = client.campaigns.update(advertiser_id, campaign['campaign_id'], update_params)
    puts "\nUpdated campaign name to: #{updated['campaign_name']}"
    
    # Step 8: Disable the campaign
    client.campaigns.update_status(advertiser_id, campaign['campaign_id'], 'DISABLE')
    puts "\nDisabled campaign"
    
    # Step 9: Check campaign status
    disabled_campaign = client.campaigns.get(advertiser_id, campaign['campaign_id'])
    puts "Campaign status: #{disabled_campaign['operation_status']}"
    
  rescue TiktokBusinessApi::Error => e
    puts "Error: #{e.message}"
    puts "Status code: #{e.status_code}"
    puts "Response body: #{e.body}"
  end
else
  puts "Failed to obtain access token. Error: #{response['message']}"
end