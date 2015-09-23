$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'stratosphere/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'stratosphere'
  s.version     = Stratosphere::VERSION
  s.authors     = %w(Zachary Golba)
  s.email       = %w(zak@zacharygolba.com)
  s.homepage    = 'http://stratosphere.zacharygolba.com'
  s.summary     = 'Lightning fast, easy-to-use, magic attachment handling for Ruby on Rails Applications'
  s.description = 'In today\'s day and age we have Dropbox, Google Drive, iCloud, etc. Shouldn\'t file uploading and attachment handling be easier and alot faster in Ruby on Rails Applications? Stratosphere makes it easy to upload directly to cloud storage providers at lightning fast speeds while maintaining that "magic" Ruby on Rails convention-over-configuration we all know and love.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'rails', '>= 4.2.4', '~> 4.2'
  s.add_dependency 'aws-sdk', '>= 2.1.23', '~> 2.0'
  s.add_dependency 'rmagick', '>= 2.15.4', '~> 2.15'
end
