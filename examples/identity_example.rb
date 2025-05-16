# frozen_string_literal: true

# Example of working with identities in the TikTok Business API

require "tiktok_business_api"
require "logger"

# Configure the client
TiktokBusinessApi.configure do |config|
  config.app_id = "YOUR_APP_ID"
  config.secret = "YOUR_APP_SECRET"
  config.access_token = "YOUR_ACCESS_TOKEN"
  config.debug = true
  config.logger = Logger.new($stdout)
end

# Initialize a client
client = TiktokBusinessApi.client

# Advertiser ID to work with
advertiser_id = "YOUR_ADVERTISER_ID"

# Example 1: List all identities
puts "Listing all identities for advertiser #{advertiser_id}:"
begin
  identities = client.identities.list(advertiser_id: advertiser_id)

  puts "Found #{identities["identity_list"].size} identities:"
  identities["identity_list"].each do |identity|
    puts "- #{identity["display_name"]} (ID: #{identity["identity_id"]}, Type: #{identity["identity_type"]})"
  end
rescue TiktokBusinessApi::Error => e
  puts "Error listing identities: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Response body: #{e.body}"
end

# Example 2: Create a new Custom User identity
puts "\nCreating a new Custom User identity:"
begin
  # First, upload an image to use as avatar (optional)
  image_response = client.images.upload(
    advertiser_id: advertiser_id,
    image_file: File.open("path/to/avatar.jpg") # Replace with actual path
  )

  image_id = image_response["image_id"]
  puts "Uploaded avatar image with ID: #{image_id}"

  # Create the identity
  new_identity = client.identities.create(
    advertiser_id: advertiser_id,
    display_name: "Test Identity #{Time.now.to_i}",
    image_uri: image_id
  )

  identity_id = new_identity["identity_id"]
  puts "Created new identity with ID: #{identity_id}"
rescue TiktokBusinessApi::Error => e
  puts "Error creating identity: #{e.message}"
  puts "Status code: #{e.status_code}"
  puts "Response body: #{e.body}"
end

# Example 3: Get detailed information about a specific identity
if defined?(identity_id)
  puts "\nGetting information about the newly created identity:"
  begin
    identity_info = client.identities.get_info(
      advertiser_id: advertiser_id,
      identity_id: identity_id,
      identity_type: "CUSTOMIZED_USER"
    )

    puts "Identity details:"
    puts "- Display name: #{identity_info["display_name"]}"
    puts "- ID: #{identity_info["identity_id"]}"
    puts "- Type: #{identity_info["identity_type"]}"
    puts "- Profile image: #{identity_info["profile_image_url"]}"
  rescue TiktokBusinessApi::Error => e
    puts "Error getting identity info: #{e.message}"
    puts "Status code: #{e.status_code}"
    puts "Response body: #{e.body}"
  end
end

# Example 4: List all identities with pagination
puts "\nListing all identities with pagination (using list_all method):"
begin
  client.identities.list_all(advertiser_id: advertiser_id) do |identity|
    puts "- #{identity["display_name"]} (ID: #{identity["identity_id"]}, Type: #{identity["identity_type"]})"
  end
rescue TiktokBusinessApi::Error => e
  puts "Error listing all identities: #{e.message}"
end

# Example 5: List identities with filtering (for CUSTOMIZED_USER type)
puts "\nListing Custom User identities with filtering:"
begin
  filtered_identities = client.identities.list(
    advertiser_id: advertiser_id,
    identity_type: "CUSTOMIZED_USER",
    filtering: {keyword: "Test"} # Filter by display name containing "Test"
  )

  puts "Found #{filtered_identities["identity_list"].size} matching identities:"
  filtered_identities["identity_list"].each do |identity|
    puts "- #{identity["display_name"]} (ID: #{identity["identity_id"]})"
  end
rescue TiktokBusinessApi::Error => e
  puts "Error listing filtered identities: #{e.message}"
end
