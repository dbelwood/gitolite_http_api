require 'grape'
require 'gitolite'
require 'entities'
require 'permission_set'

module Git
	class Api < Grape::API
		version 'v1', :using => :path
		format :json

		rescue_from :all do |e|
			Grape::API::logger.error "#{e.message}\n\n#{e.backtrace.join("\n")}"
		end

		helpers do
			def init_admin_repo!
				@@admin_repo ||= Gitolite::GitoliteAdmin.new(ENV["REPO_PATH"] + "/gitolite-admin")
			end

			def get_repo repo_name
				error!("Repository #{params[:repo_name]} does not exist.", 404) unless @@admin_repo.config.has_repo? repo_name
				@@admin_repo.config.get_repo(repo_name)
			end

			def get_group group_name
				error!("Group #{params[:group_name]} does not exist.", 404) unless @@admin_repo.config.has_group? group_name
				@@admin_repo.config.get_group(group_name)
			end

			def validate_required_fields params, *fields
				error!("#{fields.join(", ")} #{(fields.size > 1)? 'are': 'is'} required.", 500) unless fields.all? {|param| params[param]}
			end
		end

		before { init_admin_repo! }

		resource :repos do
			get do
				present @@admin_repo.config.repos.values, :with => Git::Entities::Repo, :full => true
			end

			get ':repo_name' do
				repo = get_repo params[:repo_name]
				present repo, :with => Git::Entities::Repo, :full => true
			end

			post do
				# Determine required fields are present
				validate_required_fields params, "owner", "name"
				error!("Invalid repository definition.", 500) if params[:owner].nil? or params[:name].nil?

				# Validate name attribute
				error!("#{params[:name]} is an invalid name for a repository.", 500) unless params[:name] =~ /^[\w\d\.]+$/

				repo = Gitolite::Config::Repo.new params[:name]

				repo.owner = params[:owner] unless params[:owner].nil?
				repo.description = params[:description] unless params[:description].nil?

				@@admin_repo.config.add_repo repo, true

				@@admin_repo.save_and_apply "Added repo #{params[:name]}."

				present @@admin_repo.config.get_repo(params[:name]), :with => Git::Entities::Repo
			end

			delete ':repo_name' do
				repo = get_repo params[:repo_name]
				@@admin_repo.config.rm_repo repo
				@@admin_repo.save_and_apply "Removed repo #{params[:repo_name]}."
				present repo, :with => Git::Entities::Repo, :full => true
			end

			segment '/:repo_name/permissions/:user_name' do
				get do
					repo = get_repo params[:repo_name]
					perms = PermissionSet.permissions_for_user repo, params[:user_name]
					error!("Specified user has no permissions on repo #{params[:repo_name]}.", 404) if perms.keys.size == 0
					perms
				end

				post do
					validate_required_fields params, "permissions"

					repo = get_repo params[:repo_name]
					repo.add_permission params[:permissions], "", [params[:user_name]]
					@@admin_repo.save_and_apply "Add permission #{params[:permissions]} for user #{params[:user_name]} on repo #{params[:repo_name]}."
					PermissionSet.permissions_for_user repo, params[:user_name]
				end

				put do
					validate_required_fields params, "permissions"

					repo = get_repo params[:repo_name]
					repo.add_permission params[:permissions], "", [params[:user_name]]
					@@admin_repo.save_and_apply "Updating permission #{params[:permissions]} for user #{params[:user_name]} on repo #{params[:repo_name]}."
					PermissionSet.permissions_for_user repo, params[:user_name]
				end

				delete do
					repo = get_repo params[:repo_name]
					PermissionSet.remove_permissions_for_user repo, params[:user_name]
					@@admin_repo.save_and_apply "Removing permissions for user #{params[:user_name]} on repo #{params[:repo_name]}."
				end
			end
		end

		resource :groups do
			represent Gitolite::Config::Group, :with => Git::Entities::Group
			get do
				present @@admin_repo.config.groups.values, :with => Git::Entities::Group
			end

			get ':group_name' do
				group = get_group params[:group_name]
				present group
			end

			post do
				# Determine required fields are present
				validate_required_fields params, "name"

				# Validate name attribute
				error!("#{params[:name]} is an invalid name for a group.", 500) unless params[:name] =~ /^[\w\d\.]+$/

				group = Gitolite::Config::Group.new params[:name]
				@@admin_repo.config.add_group group, true

				@@admin_repo.save_and_apply "Added group #{params[:name]}."

				present @@admin_repo.config.get_group(params[:name])
			end

			delete ':group_name' do
				group = get_group params[:group_name]
				@@admin_repo.config.rm_group group
				@@admin_repo.save_and_apply "Removed group #{params[:group_name]}."
				present group
			end

			segment '/:group_name' do
				resource '/members' do
					before { @group = get_group params[:group_name] }
					get do
						present @group.users
					end

					post do
						validate_required_fields params, "users"
						@group.add_users params[:users]
						@@admin_repo.save_and_apply "Added group members #{params[:users]}."
					end

					delete ':user_name' do
						@group.remove params[:user_name]
						@@admin_repo.save_and_apply "Removed group members #{params[:user_name]}."
					end
				end
			end
		end

		resource :keys do
			get do
				present @@admin_repo.ssh_keys[params[:email]], :with => Git::Entities::Key
			end

			post do
				validate_required_fields params, "email", "type", "blob"
				@@admin_repo.add_key Gitolite::SSHKey.new(params[:type], params[:blob], params[:email])
				@@admin_repo.save_and_apply "Added ssh key for #{params[:email]}."
				"SSH Key successfully added for #{params[:email]}."
			end
		end
	end
end