class Authorization < ActiveRecord::Base
  resourcify
  belongs_to :authorization
  belongs_to :integration
  attr_accessible :token, :secret
end
