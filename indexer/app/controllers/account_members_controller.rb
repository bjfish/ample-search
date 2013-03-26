class AccountMembersController < ApplicationController
  load_and_authorize_resource :account
  load_and_authorize_resource :account_member, :through => :account
  # GET /account_members
  # GET /account_members.json
  def index
    #@account_members = AccountMember.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @account_members }
    end
  end

  # GET /account_members/1
  # GET /account_members/1.json
  def show
    # #@account_member = AccountMember.find(params[:id])
# 
    # respond_to do |format|
      # format.html # show.html.erb
      # format.json { render json: @account_member }
    # end
  end

  # GET /account_members/new
  # GET /account_members/new.json
  # def new
  # end

  # GET /account_members/1/edit
  # def edit
    # @account_member = AccountMember.find(params[:id])
  # end

  # POST /account_members
  # POST /account_members.json
  def create
    #@account_member = AccountMember.new(params[:account_member])
    #@account = Account.find(params[:id])
    #authorize! :admin_team, @account
    if @account.user_count <= @account.account_members.count
         redirect_to account_account_members_path(@account), :notice => "Unable to add another user. Increase number of account users to add."
    else
          email = params[:email]
    user = User.find_by_email(email)
    if user.nil?
      @account.account_members.create( :email => email )
    else
      m = @account.account_members.create( :email => email)
      m.user = user # REVIEW Is this safe?
      m.save
    end
    # respond_to do |format|
      # if @account_member.save
        # format.html { redirect_to @account_member, notice: 'Account member was successfully created.' }
        # format.json { render json: @account_member, status: :created, location: @account_member }
      # else
        # format.html { render action: "new" }
        # format.json { render json: @account_member.errors, status: :unprocessable_entity }
      # end
    # end
    redirect_to account_account_members_path(@account), :notice => "Team member with email #{email} was successfully created."
 
    end

  end

  # PUT /account_members/1
  # PUT /account_members/1.json
  # def update
    # @account_member = AccountMember.find(params[:id])
# 
    # respond_to do |format|
      # if @account_member.update_attributes(params[:account_member])
        # format.html { redirect_to @account_member, notice: 'Account member was successfully updated.' }
        # format.json { head :no_content }
      # else
        # format.html { render action: "edit" }
        # format.json { render json: @account_member.errors, status: :unprocessable_entity }
      # end
    # end
  # end

  # DELETE /account_members/1
  # DELETE /account_members/1.json
  def destroy
    #@account = Account.find(params[:account_id])
    email = @account_member.email
    @account_member.destroy
    redirect_to account_account_members_path(@account), :notice => "Team member with email #{email} was successfully removed."
  end
end
