# frozen_string_literal: true

require "test_helper"

class TurfHelperTest < Minitest::Test
  def test_line_string
    line = Turf.line_string([[5, 10], [20, 40]], properties: { "name" => "test line" })
    assert_equal(line[:geometry][:coordinates][0][0], 5)
    assert_equal(line[:geometry][:coordinates][1][0], 20)
    assert_equal(line[:properties]["name"], "test line")
    assert_equal(
      Turf.line_string([[5, 10], [20, 40]])[:properties],
      {},
      "no properties case",
    )

    assert_raises(ArgumentError, "error on no coordinates") { Turf.line_string }
    exception = assert_raises(Turf::Error) do
      Turf.line_string([[5, 10]])
    end
    assert_equal(
      exception.message,
      "coordinates must be an array of two or more positions",
    )
    assert_raises(Turf::Error, "coordinates must contain numbers") do
      Turf.line_string([["xyz", 10]])
    end
    assert_raises(Turf::Error, "coordinates must contain numbers") do
      Turf.line_string([[5, "xyz"]])
    end
  end

  def test_feature_collection
    p1 = Turf.point([0, 0], properties: { "name" => "first point" })
    p2 = Turf.point([0, 10])
    p3 = Turf.point([10, 10])
    p4 = Turf.point([10, 0])
    fc = Turf.feature_collection([p1, p2, p3, p4])

    assert_equal fc[:features].length, 4
    assert_equal fc[:features][0][:properties]["name"], "first point"
    assert_equal fc[:type], "FeatureCollection"
    assert_equal fc[:features][1][:geometry][:type], "Point"
    assert_equal fc[:features][1][:geometry][:coordinates][0], 0
    assert_equal fc[:features][1][:geometry][:coordinates][1], 10
  end

  def test_point
    pt_array = Turf.point([5, 10], properties: { "name" => "test point" })

    assert_equal(pt_array[:geometry][:coordinates][0], 5)
    assert_equal(pt_array[:geometry][:coordinates][1], 10)
    assert_equal(pt_array[:properties]["name"], "test point")

    no_props = Turf.point([0, 0])
    assert_equal(no_props[:properties], {}, "no props becomes {}")
  end

  def test_polygon
    poly = Turf.polygon(
      [[[5, 10], [20, 40], [40, 0], [5, 10]]],
      properties: { "name" => "test polygon" },
    )
    assert_equal(poly[:geometry][:coordinates][0][0][0], 5)
    assert_equal(poly[:geometry][:coordinates][0][1][0], 20)
    assert_equal(poly[:geometry][:coordinates][0][2][0], 40)
    assert_equal(poly[:properties]["name"], "test polygon")
    assert_equal(poly[:geometry][:type], "Polygon")
    assert_raises(
      Turf::Error,
      /First and last Position are not equivalent/,
      "invalid ring - not wrapped",
    ) do
      assert_equal(Turf.polygon(
        [[[20.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]]],
      ).message)
    end
    assert_raises(
      Turf::Error,
      /Each LinearRing of a Polygon must have 4 or more Positions/,
      "invalid ring - too few positions",
    ) do
      assert_equal(Turf.polygon([[[20.0, 0.0], [101.0, 0.0]]]).message)
    end
    no_properties = Turf.polygon([[[5, 10], [20, 40], [40, 0], [5, 10]]])
    assert_equal(no_properties[:properties], {})
  end

  def test_degrees_to_radians
    [
      [60, Math::PI / 3],
      [270, 1.5 * Math::PI],
      [-180, -Math::PI],
    ].each do |degrees, radians|
      assert_equal radians, Turf.degrees_to_radians(degrees)
    end
  end

  def test_radians_to_length
    [
      [1, "radians", 1],
      [1, "kilometers", Turf.const_get(:EARTH_RADIUS) / 1000],
      [1, "miles", Turf.const_get(:EARTH_RADIUS) / 1609.344],
    ].each do |radians, units, length|
      assert_equal length, Turf.radians_to_length(radians, units)
    end

    assert_raises(Turf::Error) do
      Turf.radians_to_length(1, "kilograms")
    end
  end

  def test_length_to_radians
    [
      [1, "radians", 1],
      [Turf.const_get(:EARTH_RADIUS) / 1000, "kilometers", 1],
      [Turf.const_get(:EARTH_RADIUS) / 1609.344, "miles", 1],
    ].each do |length, units, radians|
      assert_equal radians, Turf.length_to_radians(length, units)
    end

    assert_raises(Turf::Error) do
      Turf.length_to_radians(1, "kilograms")
    end
  end
end
