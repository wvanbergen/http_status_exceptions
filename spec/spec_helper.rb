$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'bundler'

Bundler.setup

require 'action_controller'
require 'rspec/rails'

require 'rack/utils'
require 'http_status_exceptions'

# Include all files in the spec_helper directory
Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each do |file|
  require file
end

Spec::Runner.configure do |config|
  # nothing special
end
