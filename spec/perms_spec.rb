require 'api'
require 'json'
require 'shared_context'

describe '/repos/<repo_name>/permissions/<user_name>' do
	include_context "Admin repo handling"

	context "GET /repos/<repo_name>/permissions/<user_name>" do
		it "should return [] for a user with no permissions on a repo" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = get "/v1/repos/test_repo/permissions/dan"
			response.status.should == 404
		end
	end
	context "POST /repos/<repo_name>/permissions/<user_name>" do
		it "should add permissions to a repo" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			response = post "/v1/repos/test_repo/permissions/dan", {:permissions => "RW+"}
			response.status.should == 201
			JSON.parse(response.body).should == {"" => "RW+"}
			response = get "/v1/repos/test_repo/permissions/dan"
			response.status.should == 200
			JSON.parse(response.body).should == {"" => "RW+"}
		end
	end

	context "PUT /repos/<repo_name>/permissions/<user_name>" do
		it "should update an existing permission" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			post "/v1/repos/test_repo/permissions/dan", {:permissions => "RW+"}
			put "/v1/repos/test_repo/permissions/dan", {:permissions => "R"}
			response = get "/v1/repos/test_repo/permissions/dan"
			response.status.should == 200
			JSON.parse(response.body).should == {"" => "R"}
		end
	end
	context "DELETE /repos/<repo_name>/permissions/<user_name>" do
		it "should remove access for a given user" do
			post "/v1/repos", :name => "test_repo", :owner => "dan", :description => "A test repo."
			post "/v1/repos/test_repo/permissions/dan", {:permissions => "RW+"}
			delete "/v1/repos/test_repo/permissions/dan"
			response = get "/v1/repos/test_repo/permissions/dan"
			response.body.should == "Specified user has no permissions on repo test_repo."
			response.status.should == 404
		end
	end
end