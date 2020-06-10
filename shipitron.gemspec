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

  spec.add_runtime_dependency 'thor', '~> 1.0'
  spec.add_runtime_dependency 'aws-sdk-ecs', '~> 1.8'
  spec.add_runtime_dependency 'hashie', '~> 4.1'
  spec.add_runtime_dependency 'metaractor', '~> 3.0'
  spec.add_runtime_dependency 'diplomat', '~> 2.0'
  spec.add_runtime_dependency 'fog-aws', '~> 3.6'
  spec.add_runtime_dependency 'mime-types', '~> 3.1'
  spec.add_runtime_dependency 'minitar', '~> 0.6'
  spec.add_runtime_dependency 'mustache', '~> 1.0'
  spec.add_runtime_dependency 'tty-command', '~> 0.7'
  spec.add_runtime_dependency 'tty-table', '~> 0.9'
  spec.add_runtime_dependency 'pastel', '~> 0.7'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "pry-byebug", "~> 3.5"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "fivemat", "~> 1.3"
  spec.add_development_dependency "fog-local", "~> 0.4"
end
