# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iox-cloud/version'

Gem::Specification.new do |spec|
  spec.name          = "iox-cloud"
  spec.version       = Iox::Cloud::VERSION
  spec.authors       = ["thorsten zerha"]
  spec.email         = ["thorsten.zerha@tastenwerk.com"]
  spec.description   = %q{Cloud storage plugin combined with git let's you manage files on webpages and provide file access to different parties
}
  spec.summary       = %q{cloud storage plugin for ioxCMS}
  spec.homepage      = "https://github.com/tastenwerk/iox-cloud"
  spec.license       = "GPLv3"

  spec.files = Dir["{app,config,db,lib}/**/*", "GPLv3-LICENSE", "Rakefile", "README.rdoc"]
  #spec.files         = `git ls-files`.split($/)
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir['spec/**/*']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec-rails'

  spec.add_dependency "iox-cms", "~> 0.1.2"
  spec.add_dependency "iox-accessible-links", "~> 0.0.1"
  spec.add_dependency "rugged", "~> 0.19.0"

end
