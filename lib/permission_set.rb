class PermissionSet
	def self.to_json repo
		perms = []
		repo.permissions.each do |perm_hash|
  			perm_hash.each do |perm, list |
    			list.each do |refex, users|
    				perms << {:users => users, :refs => refex, :permission => perm}
    			end
    		end
    	end
    	perms
	end

	def self.permissions_for_user repo, user_name
		perms = {}
		repo.permissions.each do |perm_hash|
			perm_hash.each do |perm, list|
				list.each do |refex, users|
					users.each do |user|
						perms[refex] = perm if user = user_name
					end
				end
			end
		end
		perms
	end

	def self.remove_permissions_for_user repo, user_name
		repo.permissions.each do |perm_hash|
			perm_hash.each do |perm, list|
				list.each do |refex, users|
					users.each do |user|
						users.delete(user) if user = user_name
					end
				end
			end
		end
	end
end