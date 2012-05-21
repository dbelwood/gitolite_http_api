require 'permission_set'

module Git
	module Entities
		class Repo < Grape::Entity
			expose :name
			expose :owner, :unless => lambda{|model, options| model.owner.nil? or options[:full] != true }
			expose :description, :unless => lambda{|model, options| model.description.nil? or options[:full] != true }
			expose :permissions, :if => { :full => true } {| model | PermissionSet.to_json(model) }
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