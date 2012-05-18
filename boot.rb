# Add proper require paths
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), '/lib')

# Set repo path
ENV["REPO_PATH"] = File.join(File.expand_path(File.dirname(__FILE__)), '/repo')

# gitolite-admin master path
ENV["GLA_MASTER_PATH"] = "gitolite:gitolite-admin"

puts RUBY_VERSION