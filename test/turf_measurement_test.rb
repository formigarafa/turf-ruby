# frozen_string_literal: true

require "test_helper"

class TurfMeasurementTest < Minitest::Test
  def test_distance
    points = load_geojson("distance_points.geojson")
    pt2 = points[:features][1]
    pt1 = points[:features][0]

    [
      [60.35329997171344, "miles"],
      [52.44558379572202, "nauticalmiles"],
      [97.1292211896772, "kilometers"],
      [0.015245501024841969, "radians"],
      [0.8724834600465052, "degrees"],
    ].each do |distance, units|
      assert_equal(distance, Turf.distance(pt1, pt2, units: units))
    end
  end
end
