# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shipitron/version'

Gem::Specification.new do |spec|
  spec.name          = "shipitron"
  spec.version       = Shipitron::VERSION
  spec.authors       = ["Ryan Schlesinger"]
  spec.email         = ["ryan@outstand.com"]

  spec.summary       = %q{A deployment tool for use with Docker and ECS.}
  spec.homepage      = "https://github.com/outstand/shipitron"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'aws-sdk', '~> 2.4'
  spec.add_runtime_dependency 'hashie', '~> 3.4'
  spec.add_runtime_dependency 'metaractor', '~> 0.5'
  spec.add_runtime_dependency 'diplomat', '~> 0.18'
  spec.add_runtime_dependency 'fog-aws', '~> 0.11'
  spec.add_runtime_dependency 'mime-types', '~> 3.0'
  spec.add_runtime_dependency 'minitar', '~> 0.5'
  spec.add_runtime_dependency 'mustache', '~> 1.0'
  spec.add_runtime_dependency 'tty-command', '~> 0.6'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "fivemat", "~> 1.3"
  spec.add_development_dependency "fog-local", "~> 0.3"
end
