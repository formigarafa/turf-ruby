# frozen_string_literal: true

require_relative "distance"
require_relative "meta"

# :nodoc:
module Turf
  # @!group Measurement

  # Takes a GeoJSON and measures its length in the specified units, (Multi)Point 's distance are ignored.
  # @see http://turfjs.org/docs/#length
  # @param geojson [Feature<LineString|MultiLinestring>] GeoJSON to measure
  # @param units [string] can be degrees, radians, miles, or kilometers (optional, default "kilometers")
  # @return [number] length of GeoJSON
  def length(geojson, options = {})
    geojson = deep_symbolize_keys(geojson)
    geojson = feature(geojson) if geojson[:geometry].nil?
    segment_reduce(geojson, 0) do |previous_value, segment|
      previous_value ||= 0
      coords = segment.dig(:geometry, :coordinates)
      previous_value + Turf.distance(coords[0], coords[1], options)
    end
  end
end
