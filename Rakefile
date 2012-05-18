require 'rspec/core/rake_task'

desc "Default: run specs."
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
	t.pattern = "./spec/*_spec.rb"
end

desc "Setup connection to gitolite-admin master"
task :setup do |t|
	puts "Creating repo directory..."
	mkdir_p ENV["REPO_PATH"]
	puts "done."
	puts "Cloning gitolite-admin git repository into the repo path..."
	sh "cd #{ENV["REPO_PATH"]} && git clone #{ENV[GLA_MASTER_PATH]}"
	puts "done."
end