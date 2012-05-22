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
set :ssh_options, {:user => "api", :keys => [File.join(ENV["HOME"], "pems", "MMAdmin.pem"), File.join(ENV["HOME"], ".ssh", "gitolite_http_api_deploy"), File.join(ENV["HOME"], ".ssh", "server")], :forward_agent => true}
role :web, host
role :app, host
 
set :rails_env, :production
 
# Where will it be located on a server?
set :deploy_to, "/var/www/#{application}"
set :unicorn_conf, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
 
# Unicorn control tasks
namespace :deploy do
  task :init_repo do
  	run "cd #{deploy_to}/current && bundle exec rake setup"
  end

  task :create_app_service do
  	run "cd #{deploy_to}/current && bundle exec foreman export upstart /etc/init -a #{application} -u #{user} -l #{shared_path}/log"
  end

  after "deploy:create_symlink", "deploy:init_repo", "deploy:create_app_service"
  task :restart do
    run "/sbin/restart gitolite_http_api"
  end
  task :start do
    run "/sbin/start gitolite_http_api"
  end
  task :stop do
    run "/sbin/stop gitolite_http_api"
  end
end