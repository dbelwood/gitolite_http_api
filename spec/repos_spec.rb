require 'api'
require 'json'
require 'shared_context'

describe "/repos" do
	include_context "Admin repo handling"
	
	context "GET /repos" do
		it "should reply with [] if no repos exist" do
			response = get "/v1/repos"
			response.status.should == 200
			JSON.parse(response.body).should == [{"name" => "gitolite-admin", "permissions"=>[{"users"=>["admin"], "refs"=>"", "permission"=>"RW"}]}]
		end
	end
	context "POST /repos" do
		it "should successfully add a repo" do
			response = post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response.status.should == 201
			JSON.parse(response.body).should == {"name" => "test_repo"}
			response = get "/v1/repos"
			JSON.parse(response.body).should == [{"name" => "gitolite-admin", "permissions"=>[{"users"=>["admin"], "refs"=>"", "permission"=>"RW"}]}, {"name" => "test_repo", "owner" => "dan", "description" => "A test repo.", "permissions" => []}]
		end
		it "should error upon an invalid repo name" do
			response = post "/v1/repos", :name => "test repo", :owner => "dan", :description => "A test repo."
			response.status.should == 500
			response.body.should == "test repo is an invalid name for a repository."
		end
		it "should error upon adding an invalid repo" do
			response = post "/v1/repos", :invalid_attr => "test"
			response.status.should == 500
			response.body.should == "owner, name are required."
		end
	end
	context "GET /repos/<repo_id>" do 
		it "should return a repository definition for a valid repo name" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = get "/v1/repos/test_repo"
			response.status.should == 200
			JSON.parse(response.body).should == {"name" => "test_repo", "owner" => "dan", "description" => "A test repo.", "permissions" => []}
		end
		it "should return 404 for an invalid/non-existent repo name" do
			response = get '/v1/repos/non-existent-repo'
			response.status.should == 404
			response.body.should == "Repository non-existent-repo does not exist."
		end
	end
	context "DELETE /repos/<repo_id>" do
		it "should delete an existent repo" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = get "/v1/repos/"
			JSON.parse(response.body).size.should == 2
			response = delete "/v1/repos/test_repo"
			response.status.should == 200
			JSON.parse(response.body).should == {"name" => "test_repo", "owner" => "dan", "description" => "A test repo.", "permissions" => []}
			response = get "/v1/repos/"
			JSON.parse(response.body).size.should == 1
		end

		it "should not delete an non-existent repo" do
			response = delete "/v1/repos/non-existent-repo"
			response.status.should == 404
			response.body.should == "Repository non-existent-repo does not exist."
		end
	end
end