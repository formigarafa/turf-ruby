# frozen_string_literal: true

# These two lines must go first
require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "turf_ruby"
require "json"

def load_geojson(name)
  JSON.parse(
    File.read(File.expand_path("geojson/#{name}", __dir__)),
    symbolize_names: true,
  )
end

require "minitest/autorun"
require "minitest/focus"
