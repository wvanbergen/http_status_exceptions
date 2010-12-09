Gem::Specification.new do |s|
  s.name    = 'http_status_exceptions'

  # Do not update the version and date values by hand.
  # This will be done automatically by the gem release script.
  s.version = "0.2.1"
  s.date    = "2010-09-24"

  s.summary     = "A Rails plugin to use exceptions for generating HTTP status responses"
  s.description = "Clean up your controller code by raising exceptions that generate responses with different HTTP status codes."

  s.add_runtime_dependency('rack', '>= 1.2.1')
  s.add_runtime_dependency('actionpack', '>= 3')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2')

  s.authors  = ['Willem van Bergen', 'Jaap van der Meer', 'Jeff Pollard']
  s.email    = 'willem@vanbergen.org'
  s.homepage = 'http://github.com/wvanbergen/http_status_exceptions/wiki'

  # Do not update the files and test_files values by hand.
  # This will be done automatically by the gem release script.
  s.files      = %w(spec/spec_helper.rb spec/http_status_exception_spec.rb http_status_exceptions.gemspec .gitignore MIT-LICENSE lib/http_status_exceptions.rb Gemfile init.rb Rakefile README.rdoc Gemfile.lock tasks/github-gem.rake)
  s.test_files = %w(spec/http_status_exception_spec.rb)
end
