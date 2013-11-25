# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iox/cal/version'

Gem::Specification.new do |spec|
  spec.name          = "iox-cal"
  spec.version       = Iox::Cal::VERSION
  spec.authors       = ["thorsten zerha"]
  spec.email         = ["thorsten.zerha@tastenwerk.com"]
  spec.description   = %q{calendar plugin for the iox cms}
  spec.summary       = %q{calendar plugin for iox CMS}
  spec.homepage      = ""
  spec.license       = "commercial"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec-rails'

  spec.add_dependency "iox-cms", "~> 0.1.4"

end
