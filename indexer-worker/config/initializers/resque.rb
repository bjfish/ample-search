require 'resque'
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
#redis://:password@hostname:port/db_number
if Rails.env.production?
 Resque.redis = "redis://:#{ENV['REDIS_CLOUD_PASSWORD']}@#{ENV['REDIS_CLOUD_DNS']}:#{ENV['REDIS_CLOUD_PORT']}" 
end
