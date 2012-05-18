module Git
	module Entities
		class Repo < Grape::Entity
			expose :name
			expose :owner, :unless => lambda{|model, options| model.owner.nil? or options[:full] != true }
			expose :description, :unless => lambda{|model, options| model.description.nil? or options[:full] != true }
			expose :permissions, :if => { :full => true } do | model |
				perms = []
				model.permissions.each do |perm_hash|
          			perm_hash.each do |perm, list |
            			list.each do |refex, users|
            				perms << {:users => users, :refs => refex, :permission => perm}
            			end
            		end
            	end
            	perms
			end
		end

		class Group < Grape::Entity
			expose :name
			expose :users
		end

		class Key < Grape::Entity
			expose :type
			expose :email
			expose :blob
		end
	end
end