# frozen_string_literal: true

require "test_helper"

class TurfHelperTest < Minitest::Test
  def test_line_string
    line = Turf.line_string([[5, 10], [20, 40]], { "name" => "test line" })
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
    p1 = Turf.point([0, 0], { "name" => "first point" })
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
    pt_array = Turf.point([5, 10], { "name" => "test point" })

    assert_equal(pt_array[:geometry][:coordinates][0], 5)
    assert_equal(pt_array[:geometry][:coordinates][1], 10)
    assert_equal(pt_array[:properties]["name"], "test point")

    no_props = Turf.point([0, 0])
    assert_equal(no_props[:properties], {}, "no props becomes {}")
  end

  def test_polygon
    poly = Turf.polygon(
      [[[5, 10], [20, 40], [40, 0], [5, 10]]],
      { "name" => "test polygon" },
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

  def test_multi_line_string
    assert_equal(
      {
        type: "Feature",
        properties: {},
        geometry: {
          type: "MultiLineString",
          coordinates: [
            [
              [0, 0],
              [10, 10],
            ],
            [
              [5, 0],
              [15, 8],
            ],
          ],
        },
      },
      Turf.multi_line_string([
        [
          [0, 0],
          [10, 10],
        ],
        [
          [5, 0],
          [15, 8],
        ],
      ])
    )

    assert_equal(
      {
        type: "Feature",
        properties: { "test" => 23 },
        geometry: {
          type: "MultiLineString",
          coordinates: [
            [
              [0, 0],
              [10, 10],
            ],
            [
              [5, 0],
              [15, 8],
            ],
          ],
        },
      },
      Turf.multi_line_string(
        [
          [
            [0, 0],
            [10, 10],
          ],
          [
            [5, 0],
            [15, 8],
          ],
        ],
        { "test" => 23 }
      )
    )
  end

  def test_multi_point
    assert_equal(
      {
        type: "Feature",
        properties: {},
        geometry: {
          type: "MultiPoint",
          coordinates: [
            [0, 0],
            [10, 10],
          ],
        },
      },
      Turf.multi_point([
        [0, 0],
        [10, 10],
      ])
    )

    assert_equal(
      {
        type: "Feature",
        properties: { "test" => 23 },
        geometry: {
          type: "MultiPoint",
          coordinates: [
            [0, 0],
            [10, 10],
          ],
        },
      },
      Turf.multi_point(
        [
          [0, 0],
          [10, 10],
        ],
        { "test" => 23 }
      )
    )
  end

  def test_multi_polygon
    assert_equal(
      {
        type: "Feature",
        properties: {},
        geometry: {
          type: "MultiPolygon",
          coordinates: [
            [
              [
                [94, 57],
                [78, 49],
                [94, 43],
                [94, 57],
              ],
            ],
            [
              [
                [93, 19],
                [63, 7],
                [79, 0],
                [93, 19],
              ],
            ],
          ],
        },
      },
      Turf.multi_polygon([
        [
          [
            [94, 57],
            [78, 49],
            [94, 43],
            [94, 57],
          ],
        ],
        [
          [
            [93, 19],
            [63, 7],
            [79, 0],
            [93, 19],
          ],
        ],
      ])
    )

    assert_equal(
      {
        type: "Feature",
        properties: { "test" => 23 },
        geometry: {
          type: "MultiPolygon",
          coordinates: [
            [
              [
                [94, 57],
                [78, 49],
                [94, 43],
                [94, 57],
              ],
            ],
            [
              [
                [93, 19],
                [63, 7],
                [79, 0],
                [93, 19],
              ],
            ],
          ],
        },
      },
      Turf.multi_polygon(
        [
          [
            [94, 57],
            [78, 49],
            [94, 43],
            [94, 57],
          ],
        ],
        [
          [
            [93, 19],
            [63, 7],
            [79, 0],
            [93, 19],
          ],
        ],
        { "test" => 23 }
      )
    )
  end

  def test_geometry_collection
    pt = {
      type: "Point",
      coordinates: [100, 0],
    }
    line = {
      type: "LineString",
      coordinates: [
        [101, 0],
        [102, 1],
      ],
    }
    gc = Turf.geometry_collection([pt, line])

    assert_equal(
      {
        type: "Feature",
        properties: {},
        geometry: {
          type: "GeometryCollection",
          geometries: [
            {
              type: "Point",
              coordinates: [100, 0],
            },
            {
              type: "LineString",
              coordinates: [
                [101, 0],
                [102, 1],
              ],
            },
          ],
        },
      },
      gc
    )

    gc_with_props = Turf.geometry_collection([pt, line], { "a" => 23 })
    assert_equal(
      {
        type: "Feature",
        properties: { "a" => 23 },
        geometry: {
          type: "GeometryCollection",
          geometries: [
            {
              type: "Point",
              coordinates: [100, 0],
            },
            {
              type: "LineString",
              coordinates: [
                [101, 0],
                [102, 1],
              ],
            },
          ],
        },
      },
      gc_with_props
    )
  end

  def test_radians_to_degrees
    assert_equal(
      Turf.radians_to_degrees(Math::PI / 3).round(6),
      60,
      "radiance conversion PI/3"
    )
    assert_equal(Turf.radians_to_degrees(3.5 * Math::PI), 270, "radiance conversion 3.5PI")
    assert_equal(Turf.radians_to_degrees(-Math::PI), -180, "radiance conversion -PI")
  end

  def test_bearing_to_azimuth
    [
      [40, 40],
      [-105, 255],
      [410, 50],
      [-200, 160],
      [-395, 325],
    ].each do |bearing, azimuth|
      assert_equal azimuth, Turf.bearing_to_azimuth(bearing)
    end
  end

  def test_azimuth_to_bearing
    [
      [0, 0],
      [360, 0],
      [180, 180],
      [40, 40],
      [40 + 360, 40],
      [-35, -35],
      [-35 - 360, -35],
      [255, -105],
      [255 + 360, -105],
      [-200, 160],
      [-200 - 360, 160],
    ].each do |azimuth, bearing|
      assert_equal bearing, Turf.azimuth_to_bearing(azimuth)
    end
  end

  def test_round
    assert_equal round(125.123), 125
    assert_equal round(123.123, 1), 123.1
    assert_equal round(123.5), 124

    assert_raises(Turf::Error, "invalid precision") do
      round(34.5, "precision")
    end
    assert_raises(Turf::Error, "invalid precision") do
      round(34.5, -5)
    end
  end

  def test_convert_length
    assert_equal(Turf.convert_length(1000, "meters"), 1);
    assert_equal(Turf.convert_length(1000, "meters", "kilometers"), 1);
    assert_equal(Turf.convert_length(1, "kilometers", "miles"), 0.621371192237334);
    assert_equal(Turf.convert_length(1, "miles", "kilometers"), 1.609344);
    assert_equal(Turf.convert_length(1, "nauticalmiles"), 1.852);
    assert_equal(Turf.convert_length(1, "meters", "centimeters"), 100.00000000000001);
    assert_equal(Turf.convert_length(1, "meters", "yards"), 1.0936);
    assert_equal(Turf.convert_length(1, "yards", "meters"), 0.91441111923921);

    assert_equal(Turf.convert_length(Math::PI, "radians", "degrees"), 180, "PI Radians is 180 degrees");
    assert_equal(Turf.convert_length(180, "degrees", "radians"), Math::PI, "180 Degrees is PI Radians");
  end

  def test_convert_area
    [
      [1000, nil, nil, 0.001],
      [1, "kilometers", "miles", 0.386],
      [1, "miles", "kilometers", 2.5906735751295336],
      [1, "meters", "centimeters", 10000],
      [100, "meters", "acres", 0.0247105],
      [100, nil, "yards", 119.59900459999999],
      [100, "meters", "feet", 1076.3910417],
      [100000, "feet", nil, 0.009290303999749462],
      [1, "meters", "hectares", 0.0001],
    ].each do |area, from_unit, to_unit, result|
      assert_equal result, Turf.convert_area(area, from_unit, to_unit)
    end

    assert_raises(Turf::Error) do
      Turf.convert_area(1, "kilograms")
    end
  end

  def test_null_geometries
    assert_nil Turf.feature(nil)[:geometry]
    assert_nil Turf.feature_collection([Turf.feature(nil)])[:features][0][:geometry]
    assert_nil Turf.geometry_collection([Turf.feature(nil)[:geometry]])[:geometry][:geometries][0]
    assert_equal 0, Turf.geometry_collection([])[:geometry][:geometries].length
  end

  def test_handle_id_and_bbox_properties
    id = 12345
    bbox = [10, 30, 10, 30]
    pt = Turf.point([10, 30], {}, id: id, bbox: bbox)
    pt_id_0 = Turf.point([10, 30], {}, id: 0, bbox: bbox)
    fc = Turf.feature_collection([pt], id: id, bbox: bbox)

    assert_equal id, pt[:id]
    assert_equal 0, pt_id_0[:id]
    assert_equal bbox, pt[:bbox]
    assert_equal id, fc[:id]
    assert_equal bbox, fc[:bbox]
  end

  def test_is_number
    # true
    [
      123,
      1.23,
      -1.23,
      -123,
      "123".to_i,
      "1e10000".to_f,
      1e100,
      Float::INFINITY,
      -Float::INFINITY,
    ].each do |num|
      assert Turf.is_number(num)
    end

    # false
    [
      "ciao".to_f,
      "foo",
      "10px",
      Float::NAN,
      nil,
      {},
      [],
      [1, 2, 3],
      -> {},
    ].each do |non_num|
      refute Turf.is_number(non_num)
    end
  end

  def test_is_object
    # true
    assert Turf.is_object({ a: 1 })
    assert Turf.is_object({})
    assert Turf.is_object(Turf.point([0, 1]))
    assert Turf.is_object(Object.new)

    # false
    [
      123,
      Float::INFINITY,
      -123,
      "foo",
      Float::NAN,
      nil,
      [1, 2, 3],
      [],
      -> {},
    ].each do |non_obj|
      refute Turf.is_object(non_obj)
    end
  end

  def test_points
    points = Turf.points(
      [
        [-75, 39],
        [-80, 45],
        [-78, 50],
      ],
      { "foo" => "bar" },
      {id: "hello"}
    )

    assert_equal 3, points[:features].length
    assert_equal "hello", points[:id]
    assert_equal "bar", points[:features][0][:properties]["foo"]
  end

  def test_line_strings
    line_strings = Turf.line_strings(
      [
        [
          [-24, 63],
          [-23, 60],
          [-25, 65],
          [-20, 69],
        ],
        [
          [-14, 43],
          [-13, 40],
          [-15, 45],
          [-10, 49],
        ],
      ],
      { "foo" => "bar" },
      {id: "hello"}
    )

    assert_equal 2, line_strings[:features].length
    assert_equal "hello", line_strings[:id]
    assert_equal "bar", line_strings[:features][0][:properties]["foo"]
  end

  def test_polygons
    polygons = Turf.polygons(
      [
        [
          [
            [-5, 52],
            [-4, 56],
            [-2, 51],
            [-7, 54],
            [-5, 52],
          ],
        ],
        [
          [
            [-15, 42],
            [-14, 46],
            [-12, 41],
            [-17, 44],
            [-15, 42],
          ],
        ],
      ],
      { "foo" => "bar" },
      {id: "hello"}
    )

    assert_equal 2, polygons[:features].length
    assert_equal "hello", polygons[:id]
    assert_equal "bar", polygons[:features][0][:properties]["foo"]
  end

  def test_prevent_mutating_properties
    coord = [110, 45]
    properties = { "foo" => "bar" }

    pt = Turf.feature(coord, properties)
    assert_equal({ "foo" => "bar" }, pt[:properties])
    assert_equal({ "foo" => "bar" }, properties)

    properties["foo"] = "barbar"
    assert_equal({ "foo" => "barbar" }, pt[:properties])
    assert_equal({ "foo" => "barbar" }, properties)
    # If initial point shouldn't have its properties mutated
    skip("Include this test case if initial point should ~not~ have its properties mutated") do
      assert_equal({ "foo" => "bar" }, pt[:properties])
    end

    pt_mutate = Turf.feature(coord, properties)
    assert_equal({ "foo" => "barbar" }, pt_mutate[:properties])
    assert_equal({ "foo" => "barbar" }, properties)

    assert_equal({}, Turf.feature(coord)[:properties])
  end
end
