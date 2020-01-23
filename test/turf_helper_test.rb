# frozen_string_literal: true

require "test_helper"

require "turf/helper"

class TurfHelperTest < Minitest::Test
  def test_line_string
    line = Turf.line_string([[5, 10], [20, 40]], name: "test line")
    assert_equal(line[:geometry][:coordinates][0][0], 5)
    assert_equal(line[:geometry][:coordinates][1][0], 20)
    assert_equal(line[:properties][:name], "test line")
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

  def test_point
    pt_array = Turf.point([5, 10], name: "test point")

    assert_equal(pt_array[:geometry][:coordinates][0], 5)
    assert_equal(pt_array[:geometry][:coordinates][1], 10)
    assert_equal(pt_array[:properties][:name], "test point")

    no_props = Turf.point([0, 0])
    assert_equal(no_props[:properties], {}, "no props becomes {}")
  end

  def test_polygon
    poly = Turf.polygon(
      [[[5, 10], [20, 40], [40, 0], [5, 10]]],
      name: "test polygon",
    )
    assert_equal(poly[:geometry][:coordinates][0][0][0], 5)
    assert_equal(poly[:geometry][:coordinates][0][1][0], 20)
    assert_equal(poly[:geometry][:coordinates][0][2][0], 40)
    assert_equal(poly[:properties][:name], "test polygon")
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
end
