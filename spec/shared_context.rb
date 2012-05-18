shared_context "Admin repo handling" do
	OLD_REPO_ROOT ||= ENV["REPO_ROOT"]

	before(:each) do
		ENV["REPO_ROOT"] = File.join(File.expand_path(File.dirname(__FILE__)), '../test_repo')
		FileUtils.mkdir_p "#{ENV["REPO_ROOT"]}/gitolite-admin"
		Gitolite::GitoliteAdmin.bootstrap("#{ENV["REPO_ROOT"]}/gitolite-admin", {:user => "admin", :perm => "RW"})
	end

	after(:each) do
		FileUtils.rm_rf("#{ENV["REPO_ROOT"]}/")
		ENV["REPO_ROOT"] = OLD_REPO_ROOT
	end

	def app
		Git::Api
	end
end