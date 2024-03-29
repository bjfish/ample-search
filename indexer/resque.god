rails_env   = ENV['RAILS_ENV']  || "production"
queue_env   = ENV['QUEUE'] || "trello,bitbucket"
rails_root  = ENV['RAILS_ROOT'] || "/var/app/current"
num_workers = 1#rails_env == 'production' ? 5 : 2
es_url  = ENV['ELASTICSEARCH_URL'] || "http://10.76.190.47:9200"

num_workers.times do |num|
  God.watch do |w|
    w.dir      = "#{rails_root}"
    w.name     = "resque-#{num}"
    w.group    = 'resque'
    w.interval = 30.seconds
    w.env      = ENV.to_hash
    w.start    = "/usr/bin/rake -f #{rails_root}/Rakefile environment resque:work"
    w.log      = "/var/app/current/log/resque-#{num}.log"

    #w.uid = 'deploy'
    #w.gid = 'deploy'

    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end