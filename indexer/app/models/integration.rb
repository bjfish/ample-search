class Integration < ActiveRecord::Base
  resourcify
  has_many :authorizations
  has_many :users, :through => :authorizations
  attr_accessible :auth_type, :name, :url, :description
end
