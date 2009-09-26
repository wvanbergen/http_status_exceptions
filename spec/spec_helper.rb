$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec/autorun'

require 'action_controller'

require 'http_status_exceptions'

# Include all files in the spec_helper directory
Dir[File.dirname(__FILE__) + "/lib/**/*.rb"].each do |file|
  require file
end

Spec::Runner.configure do |config|
  # nothing special
end
