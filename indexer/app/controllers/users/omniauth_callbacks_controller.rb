require 'indexer_jobs'
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bitbucket
    if user_signed_in?
    @integration = Integration.find_by_name("Bitbucket")
	  auth_hash = request.env["omniauth.auth"]
    current_user.integrations << @integration
	  auth = current_user.authorizations.where(:integration_id => @integration.id).first
    auth.token = auth_hash['credentials']['token'].to_s
    auth.secret = auth_hash['credentials']['secret'].to_s
	  auth.save
    flash[:notice] = "#{@integration.name} Integration Added Successfully"
    #Resque.enqueue(BitbucketJob, auth.token, auth.secret)
    job_id = IndexerJobs::BitbucketJob.create({:token => auth.token, :secret => auth.secret, :index_id => current_user.id})
    Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
    flash[:integration_added] = true 
    redirect_to integrations_path
    end
  end

  def github
    if user_signed_in?
    @integration = Integration.find_by_name("Github")
    auth_hash = request.env["omniauth.auth"]
    current_user.integrations << @integration
    auth = current_user.authorizations.where(:integration_id => @integration.id).first
    auth.token = auth_hash['credentials']['token'].to_s
    auth.secret = auth_hash['credentials']['secret'].to_s
    auth.save
    flash[:notice] = "#{@integration.name} Integration Added Successfully"
    #Resque.enqueue(BitbucketJob, auth.token, auth.secret)
    job_id = IndexerJobs::GithubJob.create({:token => auth.token, :secret => auth.secret, :index_id => current_user.id})
    Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
    flash[:integration_added] = true 
    redirect_to integrations_path
    end
  end

    def trello
    if user_signed_in?
    @integration = Integration.find_by_name("Trello")
    auth_hash = request.env["omniauth.auth"]
    current_user.integrations << @integration
    auth = current_user.authorizations.where(:integration_id => @integration.id).first
    auth.token = auth_hash['credentials']['token'].to_s
    auth.secret = auth_hash['credentials']['secret'].to_s
    auth.save
    flash[:notice] = "#{@integration.name} Integration Added Successfully"
    #Resque.enqueue(BitbucketJob, auth.token, auth.secret)
    job_id = IndexerJobs::TrelloJob.create({:token => auth.token, :secret => auth.secret, :index_id => current_user.id})
    Rails.cache.write({:user_id => current_user.id, :integration_id => @integration.id}, job_id, :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
    flash[:integration_added] = true 
    redirect_to integrations_path
    end
  end

  def passthru
  #render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  # Or alternatively,
   raise ActionController::RoutingError.new('Not Found')
  end

end