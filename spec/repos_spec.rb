require 'api'
require 'json'

describe "/repos" do
	include Rack::Test::Methods

	after(:each) do
	end

	def app
		Git::Api
	end

	context "GET /repos" do
		it "should reply with [] if no repos exist" do
			response = get "/v1/repos"
			response.status.should == 200
			JSON.parse(response.body).should == [{"name"=>"gitolite-admin", "owner"=>nil, "description"=>nil, "permissions"=>[{"users"=>["dbelwood"], "refs"=>"", "permission"=>"RW+"}]}, {"name"=>"testing", "owner"=>nil, "description"=>nil, "permissions"=>[{"users"=>["@all"], "refs"=>"", "permission"=>"RW+"}]}]
		end
	end
	context "POST /repos" do
		it "should successfully add a repo" do
			response = post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response.status.should == 200
			JSON.parse(response.body).should == {:name => "test_repo"}
			response = get "/v1/repos"
			JSON.parse(response.body).should == [{:name => "test_repo", :description => "A test repo."}]
		end
		it "should error upon an invalid repo name" do
			response = post "/v1/repos", :name => "test repo", :owner => "dan", :description => "A test repo."
			response.status.should == 500
			JSON.parse(response.body).should == {:error => "test repo is an invalid name for a repository."}
		end
		it "should error upon adding an invalid repo" do
			response = post "/v1/repos", :invalid_attr => "test"
			response.status.should == 500
			JSON.parse(response.body).should == {:error => "Invalid repository definition."}
		end
	end
	context "GET /repos/<repo_id>" do 
		it "should return a repository definition for a valid repo name" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = get "/v1/repos/test_repo"
			response.status.should == 200
			JSON.parse(response.body).should == {:name => "test_repo", :owner => "dan", :description => "A test repo."}
		end
		it "should return 404 for an invalid/non-existent repo name" do
			response = get '/v1/repos/non-existent-repo'
			reponse.status.should == 404
		end
	end
	context "DELETE /repos/<repo_id>" do
		it "should delete an existent repo" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = get "/v1/repos/"
			JSON.parse(response.body).size.should == 1
			delete "/v1/repos/test_repo"
			response = get "/v1/repos/"
			JSON.parse(response.body).size.should == 0
		end
	end
end