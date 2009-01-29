Gem::Specification.new do |s|
  s.name    = 'http_status_exceptions'
  s.version = '0.1.4'
  s.date    = '2009-01-29'
  
  s.summary = "A Rails plugin to use exceptions for generating HTTP status responses"
  s.description = "Clean up your controller code by raising exceptions that generate responses with different HTTP status codes."
  
  s.authors  = ['Willem van Bergen']
  s.email    = ['willem@vanbergen.org']
  s.homepage = 'http://github.com/wvanbergen/http_status_exceptions/wikis'
  
  s.files = %w(MIT-LICENSE README.rdoc Rakefile init.rb lib lib/http_status_exceptions.rb tasks tasks/github-gem.rake)
end