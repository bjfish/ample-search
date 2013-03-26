class AuthorizationsController < ApplicationController
  # GET /authorizations
  # GET /authorizations.json
  # def index
    # @authorizations = Authorization.all
# 
    # respond_to do |format|
      # format.html # index.html.erb
      # format.json { render json: @authorizations }
    # end
  # end

  # GET /authorizations/1
  # GET /authorizations/1.json
  # def show
    # @authorization = Authorization.find(params[:id])
# 
    # respond_to do |format|
      # format.html # show.html.erb
      # format.json { render json: @authorization }
    # end
  # end

  # GET /authorizations/new
  # GET /authorizations/new.json
   def create
      authorize! :create, Authorization
      if user_signed_in?
        @integration = Integration.find(params[:integration_id])
        token = params[:token]
        current_user.integrations << @integration
        auth = current_user.authorizations.where(:integration_id => @integration.id).first
        auth.token = token
        auth.save
        #Resque.enqueue(TrelloJob, auth.token)
        job_id = TrelloJob.create({:token => auth.token, :index_id => current_user.id}) # TODO Refactor this
        Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
        flash[:notice] = "#{@integration.name} Integration Added Successfully"
      end
      render :json => { :redirect_url => '/integrations' }
    end

  # GET /authorizations/1/edit
  #def edit
  #  @authorization = Authorization.find(params[:id])
  #end

  # POST /authorizations
  # POST /authorizations.json
  # def create
    # @authorization = Authorization.new(params[:authorization])
# 
    # respond_to do |format|
      # if @authorization.save
        # format.html { redirect_to @authorization, notice: 'Authorization was successfully created.' }
        # format.json { render json: @authorization, status: :created, location: @authorization }
      # else
        # format.html { render action: "new" }
        # format.json { render json: @authorization.errors, status: :unprocessable_entity }
      # end
    # end
  # end

  # PUT /authorizations/1
  # PUT /authorizations/1.json
  # def update
    # @authorization = Authorization.find(params[:id])
# 
    # respond_to do |format|
      # if @authorization.update_attributes(params[:authorization])
        # format.html { redirect_to @authorization, notice: 'Authorization was successfully updated.' }
        # format.json { head :no_content }
      # else
        # format.html { render action: "edit" }
        # format.json { render json: @authorization.errors, status: :unprocessable_entity }
      # end
    # end
  # end

  # DELETE /authorizations/1
  # DELETE /authorizations/1.json
  def destroy
    @authorization = Authorization.find(params[:id])
    authorize! :delete,  @authorization
    @authorization.destroy

    respond_to do |format|
      format.html { redirect_to integrations_url }
      format.json { head :no_content }
    end
  end
  

  

  
end