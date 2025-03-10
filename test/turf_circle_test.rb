# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-circle/test.js
class TurfCircleTest < Minitest::Test
  %w[
    circle1
  ].each do |fixture|
    define_method "test_circle_#{fixture}" do
      geojson = load_geojson "circle/in/#{fixture}.geojson", symbolize_names: true
      properties = geojson[:properties] || {}
      radius = properties[:radius]
      steps = properties[:steps] || 64
      units = properties[:units]

      c = Turf.truncate(Turf.circle(geojson, radius, steps: steps, units: units))
      results = Turf.feature_collection([geojson, c])

      out = load_geojson("circle/out/#{fixture}.geojson", symbolize_names: true)
      assert_equal(out, results)
    end
  end
end
