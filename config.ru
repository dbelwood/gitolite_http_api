require './boot'
require 'api'
logger = Logger.new('log/app.log')

Grape::API::logger = logger
run Git::Api