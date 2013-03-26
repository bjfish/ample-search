class Ability
  include CanCan::Ability
  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    can :read, Integration
    logged_in = !user.nil?
    user ||= User.new # guest user (not logged in)
    if user.is_trialing || user.accounts.empty?
      can :search, Account
    end
    if logged_in && user.accounts.empty?
      can :create, Account
    end
    can :read, Account, :id => Account.with_role(:owner, user).map{ |account| account.id }
    can :update, Account, :id => Account.with_role(:owner, user).map{ |account| account.id }
    can :destroy, Account, :id => Account.with_role(:owner, user).map{ |account| account.id }
    can :read, AccountMember, :account_id => Account.with_role(:owner, user).map{ |account| account.id }
    can :create, AccountMember, :account_id => Account.with_role(:owner, user).map{ |account| account.id }
    can :destroy, AccountMember, :account_id => Account.with_role(:owner, user).map{ |account| account.id }
    if logged_in
      can :create, Integration# do | integration |
        #user.authorizations.find_by_integration_id( integration.id ).nil?
      #end
      can :retrieve, Integration# do | integration |
      #  user.authorizations.find_by_integration_id( integration.id ).nil?
      #end
      can :create, Authorization
    end

  # The first argument to `can` is the action you are giving the user permission to do.
  # If you pass :manage it will apply to every action. Other common actions here are
  # :read, :create, :update and :destroy.
  #
  # The second argument is the resource the user can perform the action on. If you pass
  # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
  #
  # The third argument is an optional hash of conditions to further filter the objects.
  # For example, here the user can only update published articles.
  #
  #   can :update, Article, :published => true
  #
  # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
