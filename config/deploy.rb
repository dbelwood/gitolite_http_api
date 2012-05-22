# Bundler tasks
require 'bundler/capistrano'

set :application, "gitolite_rest_api"
set :repository,  "git@github.com:dbelwood/gitolite_http_api.git"

set :scm, :git

# do not use sudo
set :use_sudo, false
set(:run_method) { use_sudo ? :sudo : :run }

# This is needed to correctly handle sudo password prompt
default_run_options[:pty] = true

set :user, "api"
set :group, user
set :runner, user
 
set :host, "api@ec2-184-73-92-234.compute-1.amazonaws.com" # We need to be able to SSH to that box as this user.
set :ssh_options, {:user => "api", :keys => [File.join(ENV["HOME"], "pems", "MMAdmin.pem")], :forward_agent => true}
role :web, host
role :app, host
 
set :rails_env, :production
 
# Where will it be located on a server?
set :deploy_to, "/var/www/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
 
# Unicorn control tasks
namespace :deploy do
  task :finalize_update do
  	run "cd #{deploy_to}/current && bundle exec rake setup"
  end
  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
end