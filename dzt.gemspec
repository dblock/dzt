$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'dzt/version'

Gem::Specification.new do |s|
  s.name = 'dzt'
  s.bindir = 'bin'
  s.executables << 'dzt'
  s.version = DZT::VERSION
  s.authors = ['Daniel Doubrovkine']
  s.email = 'dblock@dblock.org'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = Dir['{bin,lib}/**/*'] + Dir['*.md']
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/dblock/dzt'
  s.licenses = ['MIT']
  s.summary = 'Tile images for deep-zoom.'
  s.add_dependency 'gli'
  s.add_dependency 'rmagick'
end
