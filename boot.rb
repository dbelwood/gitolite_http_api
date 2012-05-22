# Add proper require paths
$: << File.expand_path(File.dirname(__FILE__))
$: << File.join(File.expand_path(File.dirname(__FILE__)), '/lib')

# Set repo path
ENV["REPO_PATH"] = File.join(File.expand_path(File.dirname(__FILE__)), '/repo')

# gitolite-admin master path
ENV["GLA_MASTER_PATH"] = "git@ec2-184-73-93-122.compute-1.amazonaws.com:gitolite-admin"