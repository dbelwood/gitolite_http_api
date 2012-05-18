require "rack"
require "rack/test"
require "./boot"

$: << File.join(File.expand_path(File.dirname(__FILE__)), "helpers")
require 'key_helper'

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods
  config.include KeyHelper

  def app
    Rack::Lint.new(Rack::Test::FakeApp.new)
  end

  def check(*args)
  end
end