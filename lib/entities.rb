module Git
	module Entities
		class Repo < Grape::Entity
			expose :name
			expose :owner, :if => { :full => true }
			expose :description, :if => { :full => true }
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

		class Permission
		end

		class Group
		end

		class Key
		end
	end
end