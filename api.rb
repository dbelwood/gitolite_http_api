require 'grape'
require 'gitolite'
require 'entities'

module Git
	class Api < Grape::API
		version 'v1', :using => :path
		format :json

		@@repo_path = "repo/gitolite-admin"
		@@admin_repo = Gitolite::GitoliteAdmin.new(@@repo_path)

		helpers do
			def init_admin_repo!
			end
		end

		resource :repos do
			get do
				present @@admin_repo.config.repos.values, :with => Git::Entities::Repo, :full => true
			end

			get ':repo_name' do
				present @@admin_repo.config.get_repo(params[:name]), :with => Git::Entities::Repo
			end

			post do
				# Determine required fields are present
				error!(500, "Invalid repository definition.") if params[:owner].nil?

				# Validate name attribute
				error!(500, "#{params[:name]} is an invalid name for a repository.") unless params[:name] =~ /^[\w\d\.]+$/

				repo = Gitolite::Config::Repo.new params[:name]
				repo.owner = params[:owner] unless params[:owner].nil?
				repo.description = params[:description] unless params[:description].nil?

				@@admin_repo.config.add_repo repo, true

				@@admin_repo.save_and_apply "Added repo #{params[:name]}."

				present @@admin_repo.config.get_repo(params[:name]), :with => Git::Entities::Repo
			end

			delete do
			end
		end
	end
end