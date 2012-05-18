require 'api'
require 'json'
require 'shared_context'

describe '/keys' do
	include_context "Admin repo handling"

	context "GET /keys/:email" do
		it "should return [] when there are no keys in the repo" do
			response = get "/v1/keys?email=bob%40example.com"
			response.status.should == 200
			JSON.parse(response.body).should == []
		end
	end

	context "POST /keys" do
		it "should add an ssh key" do
			key_data = get_key_data "bob@example.com"
			response = post "/v1/keys?email=bob%40example.com", :blob => key_data[:blob], :type => key_data[:type]
			puts response.body
			response.status.should == 201
			response.body.should == "SSH Key successfully added for bob@example.com."
			response = get "/v1/keys?email=bob%40example.com"
			JSON.parse(response.body).should == [{"email" => key_data[:email], "type" => key_data[:type], "blob" => key_data[:blob]}]
		end

		it "should error when not enough params are sent" do
			response = post "/v1/keys?email=bob%40example.com", :email => "bob@example.com"
			response.status.should == 500
			response.body.should == "email, type, blob are required."
		end
	end

	context "DELETE /keys/<user name>" do

	end
end