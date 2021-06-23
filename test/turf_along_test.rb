# frozen_string_literal: true

require "test_helper"

class TurfAlongTest < Minitest::Test
  def test_along
    line = load_geojson("along/dc_line.geojson")
    options = { units: "miles" }
    pt1 = Turf.along(line, 1, **options)
    pt2 = Turf.along(line["geometry"], 1.2, **options)
    pt3 = Turf.along(line, 1.4, **options)
    pt4 = Turf.along(line["geometry"], 1.6, **options)
    pt5 = Turf.along(line, 1.8, **options)
    pt6 = Turf.along(line["geometry"], 2, **options)
    pt7 = Turf.along(line, 100, **options)
    pt8 = Turf.along(line["geometry"], 0, **options)
    fc = Turf.feature_collection([pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8])

    fc[:features].each do |f|
      assert_equal f[:type], "Feature"
      assert_equal f[:geometry][:type], "Point"
    end

    assert_equal fc[:features].length, 8
    assert_equal(
      fc[:features][7][:geometry][:coordinates][0],
      pt8[:geometry][:coordinates][0],
    )
    assert_equal(
      fc[:features][7][:geometry][:coordinates][1],
      pt8[:geometry][:coordinates][1],
    )
  end
end
