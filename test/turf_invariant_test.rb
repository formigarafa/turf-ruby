# frozen_string_literal: true

require "test_helper"

class TurfInvariantTest < Minitest::Test
  def test_contains_number
    assert_equal true, Turf.contains_number([1, 1])
    assert_equal true, Turf.contains_number([[1, 1], [1, 1]])
    assert_equal true, Turf.contains_number([[[1, 1], [1, 1]], [1, 1]])

    assert_raises(Turf::Error, "coordinates must only contain numbers") do
      Turf.contains_number(["foo", 1])
    end
  end

  def test_geojson_type
    assert_raises(Turf::Error, "type and name required") do
      Turf.geojson_type()
    end

    assert_raises(Turf::Error, "type and name required") do
      Turf.geojson_type({}, nil, "myfn")
    end

    assert_raises(Turf::Error, "Invalid input to myfn: must be a Polygon, given Point") do
      Turf.geojson_type({ type: "Point", coordinates: [0, 0] }, "Polygon", "myfn")
    end

    Turf.geojson_type({ type: "Point", coordinates: [0, 0] }, "Point", "myfn")
  end

  def test_feature_of
    assert_raises(Turf::Error, "requires a name") do
      Turf.feature_of({ type: "Feature", geometry: { type: "Point", coordinates: [0, 0] }, properties: {} }, "Polygon")
    end

    assert_raises(Turf::Error, "Feature with geometry required") do
      Turf.feature_of({}, "Polygon", "foo")
    end

    assert_raises(Turf::Error, "Invalid input to myfn: must be a Polygon, given Point") do
      Turf.feature_of({ type: "Feature", geometry: { type: "Point", coordinates: [0, 0] }, properties: {} }, "Polygon", "myfn")
    end

    Turf.feature_of({ type: "Feature", geometry: { type: "Point", coordinates: [0, 0] }, properties: {} }, "Point", "myfn")
  end

  def test_collection_of
    assert_raises(Turf::Error, "Invalid input to myfn: must be a Polygon, given Point") do
      Turf.collection_of({ type: "FeatureCollection", features: [{ type: "Feature", geometry: { type: "Point", coordinates: [0, 0] }, properties: {} }] }, "Polygon", "myfn")
    end

    assert_raises(Turf::Error, "requires a name") do
      Turf.collection_of({}, "Polygon")
    end

    assert_raises(Turf::Error, "FeatureCollection required") do
      Turf.collection_of({}, "Polygon", "foo")
    end

    Turf.collection_of({ type: "FeatureCollection", features: [{ type: "Feature", geometry: { type: "Point", coordinates: [0, 0] }, properties: {} }] }, "Point", "myfn")
  end

  def test_get_coord
    assert_raises(Turf::Error, "coord must be GeoJSON Point or an Array of numbers") do
      Turf.get_coord(Turf.line_string([[1, 2], [3, 4]]))
    end
    assert_raises(Turf::Error, "coord must be GeoJSON Point or an Array of numbers") do
      Turf.get_coord(Turf.polygon([[[-75, 40], [-80, 50], [-70, 50], [-75, 40]]]))
    end

    assert_equal [1, 2], Turf.get_coord([1, 2])
    assert_equal [1, 2], Turf.get_coord(Turf.point([1, 2]))
    assert_equal [1, 2], Turf.get_coord({ type: "Point", coordinates: [1, 2] })

    assert_raises(Turf::Error) do
      Turf.get_coord({ type: "LineString", coordinates: [[1, 2], [3, 4]] })
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

  def test_get_coords
    assert_raises(Turf::Error) do
      Turf.get_coords({ type: "LineString", coordinates: nil })
    end

    assert_raises(Turf::Error) do
      Turf.get_coords(false)
    end
    assert_raises(Turf::Error) do
      Turf.get_coords(nil)
    end
    assert_raises(Turf::Error) do
      Turf.contains_number(Turf.get_coords(["A", "B", "C"]))
    end
    assert_raises(Turf::Error) do
      Turf.contains_number(Turf.get_coords([1, "foo", "bar"]))
    end

    assert_equal [[1, 2], [3, 4]], Turf.get_coords({ type: "LineString", coordinates: [[1, 2], [3, 4]] })
    assert_equal [1, 2], Turf.get_coords(Turf.point([1, 2]))
    assert_equal [[1, 2], [3, 4]], Turf.get_coords(Turf.line_string([[1, 2], [3, 4]]))
    assert_equal [1, 2], Turf.get_coords([1, 2])
  end

  def test_get_geom
    pt = Turf.point([1, 1])
    line = Turf.line_string([[0, 1], [1, 1]])
    geom_collection = Turf.geometry_collection([pt[:geometry], line[:geometry]])

    assert_equal pt[:geometry], Turf.get_geom(pt)
    assert_equal line[:geometry], Turf.get_geom(line[:geometry])
    assert_equal geom_collection[:geometry], Turf.get_geom(geom_collection)
    assert_equal geom_collection[:geometry], Turf.get_geom(geom_collection[:geometry])
  end

  def test_get_type
    pt = Turf.point([1, 1])
    line = Turf.line_string([[0, 1], [1, 1]])
    collection = Turf.feature_collection([pt, line])
    geom_collection = Turf.geometry_collection([pt[:geometry], line[:geometry]])

    assert_equal "Point", Turf.get_type(pt)
    assert_equal "LineString", Turf.get_type(line[:geometry])
    assert_equal "GeometryCollection", Turf.get_type(geom_collection)
    assert_equal "FeatureCollection", Turf.get_type(collection)
  end

  def test_null_geometries
    null_feature = { type: "Feature", properties: {}, geometry: nil }

    assert_raises(Turf::Error, "coords must be GeoJSON Feature, Geometry Object or an Array") do
      Turf.get_coords(null_feature)
    end
    assert_raises(Turf::Error, "coord must be GeoJSON Point or an Array of numbers") do
      Turf.get_coord(null_feature)
    end
  end
end
