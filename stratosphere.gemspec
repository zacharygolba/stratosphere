$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'stratosphere/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'stratosphere'
  s.version     = Stratosphere::VERSION
  s.authors     = %w(Zachary Golba)
  s.email       = %w(zak@zacharygolba.com)
  s.homepage    = 'https://github.com/zacharygolba/stratosphere'
  s.summary     = 'Attachments in the cloud.'
  s.description = ''
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 4.2.0', '~> 4.2'
  s.add_dependency 'aws-sdk', '>= 2.0.22', '~> 2.0'
  s.add_dependency 'rmagick', '>= 2.13.4', '~> 2.13'
end