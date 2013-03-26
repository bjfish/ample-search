# Load the rails application
require File.expand_path('../application', __FILE__)

Indexer::Application.configure do
  config.github_api_key = ENV['GITHUB_API_KEY']
  config.github_api_secret = ENV['GITHUB_API_SECRET']
  config.bitbucket_api_key = ENV['BITBUCKET_API_KEY']
  config.bitbucket_api_secret = ENV['BITBUCKET_API_SECRET']
end

# Initialize the rails application
Indexer::Application.initialize!
