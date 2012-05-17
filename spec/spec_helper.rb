require "rack"
require "rack/test"
require "./boot"

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods

  def app
    Rack::Lint.new(Rack::Test::FakeApp.new)
  end

  def check(*args)
  end
end