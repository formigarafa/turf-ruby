# frozen_string_literal: true

require "test_helper"

# https://github.com/Turfjs/turf/blob/master/packages/turf-invariant/test.js
class TurfInvariantTest < Minitest::Test
  def test_get_coord
    assert_raises(
      Turf::Error,
      "coord must be GeoJSON Point or an Array of numbers",
    ) do
      Turf.get_coord(Turf.line_string([[1, 2], [3, 4]]))
    end
    assert_raises(
      Turf::Error,
      "coord must be GeoJSON Point or an Array of numbers",
    ) do
      Turf.get_coord(
        Turf.polygon(
          [
            [[-75, 40], [-80, 50], [-70, 50], [-75, 40]],
          ],
        ),
      )
    end

    assert_equal [1, 2], Turf.get_coord([1, 2])
    assert_equal [1, 2], Turf.get_coord(Turf.point([1, 2]))
    assert_equal [1, 2], Turf.get_coord(
      type: "Point",
      coordinates: [1, 2],
    )

    assert_raises(Turf::Error) do
      Turf.get_coord(
        type: "LineString",
        coordinates: [[1, 2], [3, 4]],
      )
    end

    assert_raises(Turf::Error, "false should throw Error") do
      Turf.get_coord(false)
    end
    assert_raises(Turf::Error, "null should throw Error") do
      Turf.get_coord(nil)
    end
    assert_raises(Turf::Error, "LineString is not a Point") do
      Turf.get_coord(Turf.line_string([[1, 2], [3, 4]]))
    end
    assert_raises(Turf::Error, "Single number Array should throw Error") do
      Turf.get_coord([10])
    end
  end

  def test_get_geom
    pt = Turf.point([1, 1])
    line = Turf.line_string([[0, 1], [1, 1]])
    # collection = featureCollection([pt, line])
    # geomCollection = geometryCollection([pt.geometry, line.geometry])

    assert_equal(Turf.get_geom(pt), pt[:geometry], "Point")
    assert_equal(Turf.get_geom(line[:geometry]), line[:geometry], "LineString")
    # t.deepEqual(invariant.getGeom(geomCollection), geomCollection.geometry,
    # "GeometryCollection")
    # t.deepEqual(invariant.getGeom(geomCollection.geometry),
    # geomCollection.geometry, "GeometryCollection")
  end
end
