# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scl/version"

Gem::Specification.new do |spec|
  spec.name          = "scl"
  spec.version       = Scl::VERSION
  spec.authors       = ["Wouter Coppieters"]
  spec.email         = ["wouter@youdo.co.nz"]

  spec.summary       = "Simple crypto library"
  spec.description   = "Simple crypto library"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug"
end
