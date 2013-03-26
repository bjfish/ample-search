# -*- encoding: utf-8 -*-
require File.expand_path('../lib/indexer_jobs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brandon Fish"]
  gem.email         = ["brandon.j.fish@gmail.com"]
  gem.description   = %q{Contains resque jobs for indexer}
  gem.summary       = %q{Background jobs needed for indexing}
  gem.homepage      = ""

  gem.files         = Dir.glob('**/*')
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "indexer_jobs"
  gem.require_paths = ["lib"]
  gem.version       = IndexerJobs::VERSION
  gem.add_runtime_dependency  "resque", "~> 1.23.0"
  gem.add_runtime_dependency "resque-status", "~> 0.4.0"
  gem.add_runtime_dependency "github_api", "~> 0.8.1"
  gem.add_runtime_dependency "ruby-trello", "~> 0.4.4"
  gem.add_runtime_dependency "tire", "~> 0.5.0"
  gem.add_runtime_dependency "bitbucket_rest_api", "~> 0.1.1"

end
