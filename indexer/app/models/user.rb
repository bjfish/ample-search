require "uuid_helper"


class FullNameValidator < ActiveModel::Validator
  def validate(record)
    unless record.full_name.nil?
      if record.full_name.split(' ', 2).size < 2
        record.errors[:base] << "Full name must contain space in the middle"
      end
    end 
  end
end

class User < ActiveRecord::Base
  rolify
  include UUIDHelper
  has_many :authorizations
  has_many :integrations, :through => :authorizations
  has_many :account_members
  has_many :accounts, :through => :account_members
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :uuid, :trial_expiry, :time_zone, :full_name, :terms, :first_name, :last_name
  # attr_accessible :title, :body
  before_create :set_trial
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name)
  validates_acceptance_of :terms
  validates_with FullNameValidator

  def set_trial
    self.trial_expiry = Time.now + 7.days #TODO make the days configurable
  end
  
  def is_trialing
    !is_subscribed
  end
  
  def is_trial_expired
    self.trial_expiry < Time.zone.now
  end
  
  def is_subscribed
    self.accounts.size > 0
  end
  
  def admin?
    false
  end
  
  def full_name
    [first_name, last_name].join(' ')
  end

  def full_name=(name)
    split = name.split(' ', 2)
    self.first_name = split[0]
    self.last_name = split[1]
  end


  
end

