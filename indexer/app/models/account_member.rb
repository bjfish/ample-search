class AccountMember < ActiveRecord::Base
  attr_accessible :email
  belongs_to :user
  belongs_to :account
end
