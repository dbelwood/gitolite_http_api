shared_context "Admin repo handling" do
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
end