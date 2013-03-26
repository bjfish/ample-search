class AdminAbility
  include CanCan::Ability
 
  def initialize(user)
    user ||= AdminUser.new
    
    can :manage, User
    can :manage, Integration
    
  end
end