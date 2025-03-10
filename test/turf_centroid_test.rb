# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-centroid/test.js
class TurfCentroidTest < Minitest::Test
  # feature-collection
  # linestring
  # point
  # imbalanced-polygon
  %w[
    polygon
  ].each do |name|
    define_method "test_centroid_#{name}" do
      geojson = load_geojson "centroid/in/#{name}.geojson"
      out = load_geojson "centroid/out/#{name}.geojson", symbolize_names: true
      centered = Turf.centroid geojson, properties: { "marker-symbol": "circle" }
      results = Turf.feature_collection [centered]
      Turf.feature_each geojson do |feature|
        results[:features].push feature
      end
      assert_equal(out, results)
    end
  end
end
