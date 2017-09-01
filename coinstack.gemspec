# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'coinstack/version'

Gem::Specification.new do |spec|
  spec.name          = 'coinstack'
  spec.version       = Coinstack::VERSION
  spec.authors       = ['tnorthb']
  spec.email         = ['']

  spec.summary       = 'Crypto portfolio monitoring CLI.'
  spec.description   = 'Monitor the value of your crypto portfolio.'
  spec.homepage      = 'https://github.com/tnorthb/coinstack'
  spec.license       = 'MIT'

  spec.required_ruby_version     = '>= 2.2.2'
  spec.required_rubygems_version = '>= 1.8.11'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = ['coinstack']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
end
