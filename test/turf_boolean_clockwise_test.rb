# frozen_string_literal: true

require "test_helper"

class TurfBooleanClockwiseTest < Minitest::Test
  def test_is_clockwise_fixtures
    # True Fixtures
    Dir.glob(File.join(__dir__, "boolean_clockwise/true/*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath))
      feature = geojson["features"].first
      assert(Turf.boolean_clockwise(feature), "[true] #{name}")
    end

    # False Fixtures
    Dir.glob(File.join(__dir__, "boolean_clockwise/false/*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath))
      feature = geojson["features"].first
      refute(Turf.boolean_clockwise(feature), "[false] #{name}")
    end
  end

  def test_is_clockwise
    cw_array = [
      [0, 0],
      [1, 1],
      [1, 0],
      [0, 0],
    ]
    ccw_array = [
      [0, 0],
      [1, 0],
      [1, 1],
      [0, 0],
    ]

    assert_equal(true, Turf.boolean_clockwise(cw_array), "[true] clockwise array input")
    assert_equal(false, Turf.boolean_clockwise(ccw_array), "[false] counter-clockwise array input")
  end

  def test_is_clockwise_geometry_types
    line = Turf.line_string([
      [0, 0],
      [1, 1],
      [1, 0],
      [0, 0],
    ])

    assert_equal(true, Turf.boolean_clockwise(line), "Feature")
    assert_equal(true, Turf.boolean_clockwise(line[:geometry]), "Geometry Object")
  end

  # Uncomment the following test if exception handling for unsupported geometry types is implemented
  #
  # def test_is_clockwise_throws
  #   pt = Turf.point([-10, -33])
  #   assert_raises do
  #     Turf.boolean_clockwise(pt)
  #   end
  # end
end
