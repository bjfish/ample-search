require "tire"
Tire.configure do
  url ENV['ELASTICSEARCH_URL']
end