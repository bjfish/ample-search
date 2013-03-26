require "indexer_jobs/version"

require "github_api"
require 'resque/job_with_status'
require 'net/http'
require 'json'
require 'uri'
require 'trello'
require 'tire'
require 'resque'
require 'bitbucket_rest_api'

module IndexerJobs


class GithubJob
	  include Resque::Plugins::Status

	@queue = :github

	def perform
	  Tire.configure do
		url ENV['ELASTICSEARCH_URL']
	  end
	  at(1, 100, "Indexing started")
	  token = options['token']
	  secret = options['secret']
	  index_id = options['index_id']

	  github = Github.new oauth_token: token

	  at(50, 100, "Retrieving documents")
	  all_issues = github.issues.list

	  Tire.index index_id do
		import all_issues  do |documents|
		  documents.each do |document|
			document[:type] = :github_issue
			document[:appname] = "Github"
			document[:appdocname] = "Issue"
			document[:name] = document['title']
			document[:id] = document['id']
			document[:url] = document['html_url']
		  end
		end
	  end
	  at(100, 100, "Indexing Completed")
	  completed "Indexing completed"
	  end
	  
	  def update_document_count(index_id)
		  uri = URI.parse("#{ENV['ELASTICSEARCH_URL']}/#{index_id}/_count") #TODO Cache this count
		  response = Net::HTTP.get_response(uri)
		  hash = JSON.parse response.body
		  count = hash["count"]
		  Rails.cache.write({:user_id => index_id, :name => :document_count}, count)
	  end
	  
	end
	


class BitbucketJob
  include Resque::Plugins::Status
  @queue = :bitbucket

  def perform
    es_url = ENV['ELASTICSEARCH_URL']
    Tire.configure do
      url es_url
    end
    at(1, 100, "Indexing started")
    token = options['token']
    secret = options['secret']
	  index_id = options['index_id']

    bitbucket = BitBucket.new do |config|
      config.oauth_token  = token
      config.oauth_secret = secret
      config.client_id = ENV['BITBUCKET_API_KEY']
      config.client_secret = ENV['BITBUCKET_API_SECRET']
      config.adapter      = :net_http
    end
    
    at(50, 100, "Retrieving documents")
    all_issues = []
    bitbucket.repos.list do |repo|
      if repo.has_issues
        issues = bitbucket.issues.list_repo repo.owner, repo.slug
        all_issues += issues
      end
    end
    Tire.index index_id do
      create
      import all_issues  do |documents|
        documents.each do |document|
          document[:type] = :bitbucket_issue
          document[:appname] = "Bitbucket"
          document[:appdocname] = "Issue"
          document[:name] = document['title']
		      document[:id] = document[:resource_uri]
          document[:url] = "https://bitbucket.org" + document[:resource_uri][17..-1]
        end
      end
    end
    at(100, 100, "Indexing Completed")
    completed "Indexing completed"
  end
 
  
end
	



class TrelloJob
  #extend Resque::Plugins::Logger
  include Resque::Plugins::Status
  include Trello
  include Trello::Authorization
  

  @queue = :trello

  def perform
    es_url = ENV['ELASTICSEARCH_URL']

    at(1, 100, "Indexing started")
    token = options['token']
    index_id = options['index_id']
    key = ENV['TRELLO_API_KEY']
    secret = ENV['TRELLO_API_SECRET']
    params = [token, index_id, key, secret, es_url]
    raise "Missing parameter" if params.include?(nil)
    
    Tire.configure do
      url es_url# TODO FIX ME NOW
      #logger 'elasticsearch.log', :level => 'debug'
    end
    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
    OAuthPolicy.consumer_credential = OAuthCredential.new key, secret
    OAuthPolicy.token = OAuthCredential.new token, nil

    me = Member.find("me")
    boards = me.boards(:filter => :all)

    all_cards = []
    at(50, 100, "Retrieving documents")
    boards.each do |board|
      cards = board.cards
      cards.each do |card|
        all_cards << card.attributes
      end
    end
    
    index = Tire.index(index_id)
    index.create unless index.exists?

    Tire.index index_id do
      import all_cards  do |documents|
       documents.each do |document|
           document[:type] = :trello_card
           document[:appname] = "Trello"
           document[:appdocname] = "Card"
       end
      end
    end
    at(99, 100, "Indexing Completed")
    completed "Indexing completed"
  end
end



	
end
