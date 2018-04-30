
Gem::Specification.new do |s|

  s.name = 'dense'

  s.version = File.read(
    File.expand_path('../lib/dense.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux+flor@gmail.com' ]
  s.homepage = 'http://github.com/floraison/dense'
  s.license = 'MIT'
  s.summary = 'fetching deep in a dense structure'

  s.description = %{
Fetching deep in a dense structure. A kind of bastard of JSONPath.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  s.add_runtime_dependency 'raabro', '>= 1.1.5'

  s.add_development_dependency 'rspec', '~> 3.7'

  s.require_path = 'lib'
end

