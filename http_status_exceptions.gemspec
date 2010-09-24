Gem::Specification.new do |s|
  s.name    = 'http_status_exceptions'

  # Do not update the version and date values by hand.
  # This will be done automatically by the gem release script.
  s.version = "0.2.0"
  s.date    = "2009-10-07"

  s.summary     = "A Rails plugin to use exceptions for generating HTTP status responses"
  s.description = "Clean up your controller code by raising exceptions that generate responses with different HTTP status codes."

  s.add_runtime_dependency('actionpack', '~> 2')

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')

  s.authors  = ['Willem van Bergen']
  s.email    = ['willem@vanbergen.org']
  s.homepage = 'http://github.com/wvanbergen/http_status_exceptions/wikis'

  # Do not update the files and test_files values by hand.
  # This will be done automatically by the gem release script.
  s.files      = %w(spec/spec_helper.rb http_status_exceptions.gemspec .gitignore init.rb lib/http_status_exceptions.rb Rakefile MIT-LICENSE tasks/github-gem.rake README.rdoc spec/http_status_exception_spec.rb)
  s.test_files = %w(spec/http_status_exception_spec.rb)
end