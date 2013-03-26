require 'trello'
require 'rest_client'
require "omniauth"
require 'oauth'
require 'bitbucket_rest_api'
require 'indexer_jobs'

class IntegrationsController < ApplicationController
  load_and_authorize_resource :except => [:index_now, :job_status]
  # GET /integrations
  # GET /integrations.json
  def index
      #@integrations = Integration.all #loaded automatically
      @statuses = {}
      if user_signed_in?
        @integrations.each do |integration|
          user_integration_hash = Rails.cache.read(:user_id => current_user.id, :integration_id => integration.id)
          status = Resque::Plugins::Status::Hash.get(user_integration_hash)
          if status.nil?
            @statuses[integration.id] = ''
          else
            if status.status == "queued"
              @statuses[integration.id] = 'Indexing started'
            else
            @statuses[integration.id] = status.message
            end
          end
        end
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @integrations }
        end
      end
    end

  # GET /integrations/1
  # GET /integrations/1.json
  #def show
  #  @integration = Integration.find(params[:id])
  #
  #  respond_to do |format|
  #    format.html # show.html.erb
  #    format.json { render json: @integration }
  #  end
  #end

  # GET /integrations/new
  # GET /integrations/new.json
  #def new
  #  @integration = Integration.new
  #
  #  respond_to do |format|
  #    format.html # new.html.erb
  #    format.json { render json: @integration }
  #  end
  #end

  # GET /integrations/1/edit
  #def edit
  #  @integration = Integration.find(params[:id])
  #end

  # POST /integrations
  # POST /integrations.json
  #def create
  #  @integration = Integration.new(params[:integration])
  #
  #  respond_to do |format|
  #    if @integration.save
  #      format.html { redirect_to @integration, notice: 'Integration was successfully created.' }
  #      format.json { render json: @integration, status: :created, location: @integration }
  #    else
  #      format.html { render action: "new" }
  #      format.json { render json: @integration.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # PUT /integrations/1
  # PUT /integrations/1.json
  #def update
  #  @integration = Integration.find(params[:id])
  #
  #  respond_to do |format|
  #    if @integration.update_attributes(params[:integration])
  #      format.html { redirect_to @integration, notice: 'Integration was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: "edit" }
  #      format.json { render json: @integration.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /integrations/1
  # DELETE /integrations/1.json
  #def destroy
  #  @integration = Integration.find(params[:id])
  #  @integration.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to integrations_url }
  #    format.json { head :no_content }
  #  end
  #end
  

  


  #Controlller method used for testing integration code
  #def trello
  #  @integration = Integration.find(1)
  #  auth = current_user.authorizations.where(:integration_id => @integration.id).first
  #  Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
  #  OAuthPolicy.consumer_credential = OAuthCredential.new ENV['TRELLO_API_KEY'], ENV['TRELLO_API_SECRET']
  #  OAuthPolicy.token = OAuthCredential.new auth.token, nil
  #
  #  me = Member.find("me")
  #  boards = me.boards(:filter => :all)
  #
  #  all_cards = []
  #
  #  boards.each do |board|
  #    cards = board.cards
  #    cards.each do |card|
  #      all_cards << card.attributes
  #    end
  #  end
  #  render :text => all_cards
  #end

  #Controlller method used for testing integration code
  #def bitbucket
  #  @integration = Integration.find_by_name("Bitbucket")
  #  auth = current_user.authorizations.where(:integration_id => @integration.id).first
  #
  #  bitbucket = BitBucket.new do |config|
  #    config.oauth_token  = auth.token
  #    config.oauth_secret = auth.secret
  #    config.client_id = ENV['BITBUCKET_API_KEY']
  #    config.client_secret = ENV['BITBUCKET_API_SECRET']
  #    config.adapter      = :net_http
  #  end
  #
  #  all_issues = []
  #  bitbucket.repos.list do |repo|
  #     issues = bitbucket.issues.list_repo repo.owner, repo.slug
	 #  issues.each do |i|
  #       issue = bitbucket.issues.get repo.owner, repo.slug, i.local_id
		# all_issues << issue
	 #  end
  #  end
  #  render :json => all_issues
  #end

  def job_status
    if user_signed_in?
    integration_id = params[:id]
    authorize! :retrieve, Integration
    job_id = Rails.cache.read(:user_id => current_user.id, :integration_id => integration_id)
    status = Resque::Plugins::Status::Hash.get(job_id)
    response = {}
    unless status.nil?
      response[:integration_id] = integration_id
      response[:message] = status["message"]
      response[:status] = status["status"]
    end
    render :json =>  response
    else
      render :json => {}
    end
  end
  
      # GET /integrations/1/retrieve
  def index_now #means index now
    if user_signed_in?
      @integration = Integration.find(params[:id])
      authorize! :retrieve, Integration
      auth = current_user.authorizations.where(:integration_id => @integration.id).first
      if @integration.name == "Trello"
        job_id = IndexerJobs::TrelloJob.create({:token => auth.token, :index_id => current_user.id})
        Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
      elsif @integration.name == "Bitbucket"
        job_id = IndexerJobs::BitbucketJob.create({:token => auth.token, :secret => auth.secret, :index_id => current_user.id})
        Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
      elsif @integration.name == "Github"
        job_id = IndexerJobs::GithubJob.create({:token => auth.token, :secret => auth.secret, :index_id => current_user.id})
        Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
      end
      render :json => {:id => @integration.id}
    else
      render :json => {}
    end
  end
  
end
