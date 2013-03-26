#Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
#Resque.redis = "your/redis/socket" # default localhost:6379
require 'resque'
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
#redis://:password@hostname:port/db_number
if Rails.env.production?
 Resque.redis = "redis://:#{ENV['REDIS_CLOUD_PASSWORD']}@#{ENV['REDIS_CLOUD_DNS']}:#{ENV['REDIS_CLOUD_PORT']}" 
end

log_path = File.join Rails.root, 'log'

config = {
  folder:     log_path,                 # destination folder
  class_name: Logger,                   # logger class name
  class_args: [ 'daily', 1.kilobyte ],  # logger additional parameters
  level:      Logger::INFO,             # optional
  formatter:  Logger::Formatter.new,    # optional
}

Resque.logger = config