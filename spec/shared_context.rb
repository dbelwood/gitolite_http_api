shared_context "Admin repo handling" do
	OLD_REPO_PATH ||= ENV["REPO_PATH"]

	before(:each) do
		ENV["REPO_PATH"] = File.join(File.expand_path(File.dirname(__FILE__)), '../test_repo')
		FileUtils.mkdir_p "#{ENV["REPO_PATH"]}/gitolite-admin"
		Gitolite::GitoliteAdmin.bootstrap("#{ENV["REPO_PATH"]}/gitolite-admin", {:user => "admin", :perm => "RW"})
	end

	after(:each) do
		FileUtils.rm_rf("#{ENV["REPO_PATH"]}/")
		ENV["REPO_PATH"] = OLD_REPO_PATH
	end

	def app
		Git::Api
	end
end