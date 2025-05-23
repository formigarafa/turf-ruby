# frozen_string_literal: true

require_relative "lib/turf/version"

Gem::Specification.new do |spec|
  spec.name          = "turf-ruby"
  spec.version       = Turf::VERSION
  spec.authors       = ["Rafael Santos"]
  spec.email         = ["formigarafa@gmail.com"]

  spec.summary       = "A modular geospatial engine. Ruby port of TurfJS."
  spec.description   = [
    "Turf Ruby is a Ruby library for spatial analysis. ",
    "It includes traditional spatial operations, helper functions for creating",
    " GeoJSON data, and data classification and statistics tools.",
  ].join
  spec.homepage      = "http://github.com/formigarafa/turf-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://formigarafa.github.io/turf-ruby/"

  spec.files = Dir["*.gemspec", "lib/**/*", "LICENSE.txt", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"
end
