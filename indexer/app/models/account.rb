class Account < ActiveRecord::Base
  resourcify
  belongs_to :creator, :class_name => "User"
  has_many :account_members
  has_many :users, :through => :account_members
  attr_accessible :customer_id, :description, :email, :last_4_digits, :stripe_token, :user_count
  attr_accessor :stripe_token
  before_save :update_stripe
  before_destroy :cancel_subscription
  validates :user_count, :numericality => { :only_integer => true, :greater_than => 0 }

  def update_stripe
    #return if email.include?('@example.com') and not Rails.env.production?
    if customer_id.nil?
      if !stripe_token.present?
        raise "Stripe token not present. Can't create account."
      end
      customer = Stripe::Customer.create(
          :email => email,
          :description => description,
          :card => stripe_token,
          :plan => 'per_user',
          :quantity => user_count
      )
    else
      customer = Stripe::Customer.retrieve(customer_id)
      if stripe_token.present?
        customer.card = stripe_token
      end
      customer.email = email
      customer.description = description
      if user_count != customer.subscription.quantity
      customer.update_subscription(:prorate => true, :plan => "per_user", :quantity => user_count)
      end
      customer.save
    end
    self.last_4_digits = customer.active_card.last4
    self.customer_id = customer.id
    self.stripe_token = nil
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "#{e.message}."
    self.stripe_token = nil
    false
  end

  def cancel_subscription
    unless customer_id.nil?
      customer = Stripe::Customer.retrieve(customer_id)
      unless customer.nil? #or customer.deleted # TODO Figure out why undefined method `deleted'
        if customer.subscription.status == 'active'
          customer.cancel_subscription
        end
      end
    end
  rescue Stripe::StripeError => e
    logger.error "Stripe Error: " + e.message
    errors.add :base, "Unable to cancel your subscription. #{e.message}."
    false
  end

end
