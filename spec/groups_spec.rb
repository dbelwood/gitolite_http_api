require 'api'
require 'json'

describe "/groups" do
	include Rack::Test::Methods

	REPO_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), '../repos').to_s

	before(:each) do
		FileUtils.mkdir_p "#{REPO_ROOT}/gitolite-admin"
		Gitolite::GitoliteAdmin.bootstrap("#{REPO_ROOT}/gitolite-admin", {:user => "admin", :perm => "RW"})
	end

	after(:each) do
		FileUtils.rm_rf("#{REPO_ROOT}/gitolite-admin")
	end

	def app
		Git::Api
	end

	context "GET /groups" do
		it "should reply with [] if no groups exist" do
			response = get "/v1/groups"
			response.status.should == 200
			JSON.parse(response.body).should == []
		end
	end
	context "POST /groups" do
		it "should successfully add a group" do
			response = post "/v1/groups", :name => "test_group"
			response.status.should == 201
			JSON.parse(response.body).should == {"name" => "test_group", "users" => []}
			response = get "/v1/groups"
			JSON.parse(response.body).should == [{"name" => "test_group", "users" => []}]
		end
		it "should error upon an invalid group name" do
			response = post "/v1/groups", :name => "test group"
			response.status.should == 500
			response.body.should == "test group is an invalid name for a group."
		end
		it "should error upon adding an group repo" do
			response = post "/v1/groups", :invalid_attr => "test"
			response.status.should == 500
			response.body.should == "Invalid group definition."
		end
	end
	context "GET /groups/<group_name>" do 
		it "should return a group definition for a valid group name" do
			post "/v1/groups", :name => "test_group"
			response = get "/v1/groups/test_group"
			response.status.should == 200
			JSON.parse(response.body).should == {"name" => "test_group", "users" => []}
		end
		it "should return 404 for an invalid/non-existent group name" do
			response = get '/v1/groups/non-existent-group'
			response.status.should == 404
			response.body.should == "Group non-existent-group does not exist."
		end
	end
	context "DELETE /groups/<group_name>" do
		it "should delete an existent group" do
			post "/v1/groups", :name => "test_group"
			response = get "/v1/groups/"
			JSON.parse(response.body).size.should == 1
			response = delete "/v1/groups/test_group"
			response.status.should == 200
			JSON.parse(response.body).should == {"name" => "test_group", "users" => []}
			response = get "/v1/groups/"
			JSON.parse(response.body).size.should == 1
		end

		it "should not delete an non-existent group" do
			response = delete "/v1/groups/non-existent-group"
			response.status.should == 404
			response.body.should == "Group non-existent-group does not exist."
		end
	end
end