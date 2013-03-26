class AccountsController < ApplicationController
  load_and_authorize_resource
  # GET /accounts
  # GET /accounts.json
  #def index
  #  @accounts = Account.all

  #  respond_to do |format|
  #    format.html # index.html.erb
  #    format.json { render json: @accounts }
  #  end
  #end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    #@account = Account.find(params[:id])
    #authorize! :show, @account
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new
    authorize! :create, Account
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
    authorize! :update, @account
  end

  # GET  /accounts/1/team
  def show_team
    @account = Account.find(params[:id])
    authorize! :view_team, @account
    @members = @account.account_members
    @member = AccountMember.new
  end

   
  # POST /accounts
  # POST /accounts.json
  def create
    #authorize! :create, Account
    #@account = Account.new(params[:account])
    @account.email = current_user.email
    @account.description = current_user.email
    
    respond_to do |format|
      if @account.save
        m = @account.account_members.create( :email => current_user.email)
        m.user = current_user
        current_user.add_role :owner, @account
        if current_user.save && m.save
        flash[:new_account] = true  
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render json: @account, status: :created, location: @account }
        else 
          format.html { render action: "new" }
          format.json { render json: @account.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = Account.find(params[:id])
    authorize! :update, @account
    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = Account.find(params[:id])
    authorize! :destroy, @account
    @account.destroy
    flash[:notice] = "Account canceled successfully."
    flash[:account_canceled] = true 
    respond_to do |format|
      format.html { redirect_to new_account_path }
      format.json { head :no_content }
    end
  end
end
