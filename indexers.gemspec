$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'indexers/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'indexers'
  s.version     = Indexers::VERSION
  s.authors     = ['mmontossi']
  s.email       = ['mmontossi@museways.com']
  s.homepage    = 'https://github.com/mmontossi/indexers'
  s.summary     = 'Search indexers for rails.'
  s.description = 'Dsl to delegate searches to elasticsearch in rails.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1'
  s.add_dependency 'elasticsearch', '~> 5.0'

  s.add_development_dependency 'pg', '~> 0.21'
  s.add_development_dependency 'mocha', '~> 1.2'
end
