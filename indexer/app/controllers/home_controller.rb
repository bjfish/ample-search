require 'tire'
require 'tire/search'
require 'net/http'
require 'json'
require 'uri'

class HomeController < ApplicationController
  skip_authorization_check
  caches_action :index, :layout => false
  
  def index
  end

  def search
    if current_user && current_user.integrations.size == 0
      redirect_to integrations_path
    end
    @count = nil
    query = params[:q]
    @query = query
    unless query.blank?
      index_id = current_user.id
      #uri = URI.parse("#{ENV['ELASTICSEARCH_URL']}/#{index_id}/_count") #TODO Cache this count
      #response = Net::HTTP.get_response(uri)
      #hash = JSON.parse response.body
      #@count = hash["count"]
      @count = Rails.cache.read(:user_id => current_user.id, :name => :document_count)
      search = Tire::Search::Search.new(index_id)
      search.query  { string(query) }
      search.highlight :name, :options => { :tag => '<strong class="highlight">'}
      @results = search.results
    end
  rescue Tire::Search::SearchRequestFailed => srf
    # TODO Fix this
    logger.error srf.message
    flash[:error] = "An error occured during search. Please try again."
    rescue => e
    logger.error e.message
	  flash[:error] = "An error has occured"
    #end
  end

end
