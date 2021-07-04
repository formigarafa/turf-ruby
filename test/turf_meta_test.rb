# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-meta/test.js
class TurfMetaTest < Minitest::Test
  def pt
    Turf.point([0, 0], properties: { a: 1 })
  end

  def pt2
    Turf.point([1, 1])
  end

  def line
    Turf.line_string([
      [0, 0],
      [1, 1],
    ])
  end

  def poly
    Turf.polygon([
      [
        [0, 0],
        [1, 1],
        [0, 1],
        [0, 0],
      ],
    ])
  end

  def poly_with_hole
    Turf.polygon([
      [
        [100.0, 0.0],
        [101.0, 0.0],
        [101.0, 1.0],
        [100.0, 1.0],
        [100.0, 0.0],
      ],
      [
        [100.2, 0.2],
        [100.8, 0.2],
        [100.8, 0.8],
        [100.2, 0.8],
        [100.2, 0.2],
      ],
    ])
  end

  def multi_pt
    Turf.multi_point([
      [0, 0],
      [1, 1],
    ])
  end

  def multi_line
    Turf.multi_line_string([
      [
        [0, 0],
        [1, 1],
      ],
      [
        [3, 3],
        [4, 4],
      ],
    ])
  end

  def multi_poly
    Turf.multi_polygon(
      [
        [
          [
            [0, 0],
            [1, 1],
            [0, 1],
            [0, 0],
          ],
        ],
        [
          [
            [3, 3],
            [2, 2],
            [1, 2],
            [3, 3],
          ],
        ],
      ],
    )
  end

  def geom_collection
    Turf.geometry_collection(
      [pt.fetch(:geometry), line.fetch(:geometry), multi_line.fetch(:geometry)],
      properties: { a: 0 },
    )
  end

  def fc_null
    Turf.feature_collection([
      Turf.feature(nil),
      Turf.feature(nil),
    ])
  end

  def fc_mixed
    Turf.feature_collection([
      Turf.point([0, 0]),
      Turf.line_string([
        [1, 1],
        [2, 2],
      ]),
      Turf.multi_line_string([
        [
          [1, 1],
          [0, 0],
        ],
        [
          [4, 4],
          [5, 5],
        ],
      ]),
    ])
  end

  def collection(feature)
    feature_collection = {
      type: "FeatureCollection",
      features: [feature]
    }

    [feature, feature_collection]
  end

  def feature_and_collection(geometry)
    feature = {
      type: "Feature",
      geometry: geometry,
      properties: { a: 1 }
    }

    feature_collection = {
      type: "FeatureCollection",
      features: [feature]
    }

    [geometry, feature, feature_collection]
  end

  def test_coord_each_point
    feature_and_collection(pt[:geometry]).each do |input|
      Turf.coord_each input do |coord, index|
        assert_equal [0, 0], coord
        assert_equal 0, index
      end
    end
  end

  def test_coord_each_line_string
    feature_and_collection(line[:geometry]).each do |input|
      output = []
      Turf.coord_each input do |coord, index|
        output.push [coord, index]
      end
      assert_equal(
        [
          [[0, 0], 0],
          [[1, 1], 1],
        ],
        output,
      )
    end
  end

  def test_coord_each_polygon
    feature_and_collection(poly[:geometry]).each do |input|
      output = []
      Turf.coord_each input do |coord, index|
        output.push [coord, index]
      end
      assert_equal(
        [
          [[0, 0], 0],
          [[1, 1], 1],
          [[0, 1], 2],
          [[0, 0], 3],
        ],
        output,
      )
    end
  end

  def test_coord_each_polygon_exclude_wrap_coord
    feature_and_collection(poly[:geometry]).each do |input|
      output = []
      Turf.coord_each input, exclude_wrap_coord: true do |coord, index|
        output.push [coord, index]
      end
      assert_equal(
        [
          [[0, 0], 0],
          [[1, 1], 1],
          [[0, 1], 2],
        ],
        output,
      )
    end
  end

  def test_coord_each_multi_polygon
    feature_and_collection(multi_poly).each do |input|
      output = []
      Turf.coord_each input do |coord, index|
        output.push [coord, index]
      end
      assert_equal(
        [
          [[0, 0], 0],
          [[1, 1], 1],
          [[0, 1], 2],
          [[0, 0], 3],
          [[3, 3], 4],
          [[2, 2], 5],
          [[1, 2], 6],
          [[3, 3], 7],
        ],
        output,
      )
    end
  end

  def test_coord_each_feature_collection
    output = []
    Turf.coord_each fc_mixed do |coord, index|
      output.push [coord, index]
    end
    assert_equal(
      [
        [[0, 0], 0],
        [[1, 1], 1],
        [[2, 2], 2],
        [[1, 1], 3],
        [[0, 0], 4],
        [[4, 4], 5],
        [[5, 5], 6],
      ],
      output,
    )
  end

  def test_coord_reduce_initial_value
    output = []
    line = Turf.line_string([
      [126, -11],
      [129, -21],
      [135, -31],
    ])
    sum = Turf.coord_reduce(
      line,
      initial_value: 0,
    ) do |previous, coords, index|
      output.push [previous, coords, index]
      previous + coords[0]
    end

    assert_equal([
      [0, [126, -11], 0],
      [126, [129, -21], 1],
      [255, [135, -31], 2],
    ], output)
    assert_equal(390, sum)
  end

  def test_coord_reduce_previous_coordinates
    output = []
    line = Turf.line_string([
      [126, -11],
      [129, -21],
      [135, -31],
    ])
    Turf.coord_reduce(
      line,
    ) do |previous, coords, index|
      output.push [previous, coords, index]
      coords
    end

    assert_equal([
      [[126, -11], [129, -21], 1],
      [[129, -21], [135, -31], 2],
    ], output)
  end

  def test_coord_reduce_previous_coordinates_initial_value
    output = []
    Turf.coord_reduce(
      line,
      initial_value: line.fetch(:geometry).fetch(:coordinates)[0],
    ) do |previous, coords, index|
      output.push [previous, coords, index]
      coords
    end

    assert_equal([
      [[0, 0], [0, 0], 0],
      [[0, 0], [1, 1], 1],
    ], output)
  end

  def test_coord_each_error
    assert_raises_with_message(Turf::Error, "Unknown Geometry Type: ") do
      Turf.coord_each({})
    end
  end

  def test_geom_each_geometry_collection
    feature_and_collection(geom_collection.fetch(:geometry)).each do |input|
      output = []
      Turf.geom_each input do |geom|
        output.push geom
      end
      assert_equal(
        geom_collection.fetch(:geometry).fetch(:geometries),
        output,
      )
    end
  end

  def test_geom_each_bare_geometry_collection
    output = []
    Turf.geom_each geom_collection do |geom|
      output.push geom
    end
    assert_equal(
      geom_collection.fetch(:geometry).fetch(:geometries),
      output,
    )
  end

  def test_geom_each_bare_point_geometry
    output = []
    Turf.geom_each(pt.fetch(:geometry)) do |geom|
      output.push geom
    end
    assert_equal(
      [pt.fetch(:geometry)],
      output,
    )
  end

  def test_geom_each_bare_point_feature
    output = []
    Turf.geom_each(pt) do |geom|
      output.push geom
    end
    assert_equal(
      [pt.fetch(:geometry)],
      output,
    )
  end

  def test_geom_each_multi_geometry_feature_properties
    last_properties = nil
    Turf.geom_each(geom_collection) do |_geom, _index, properties|
      last_properties = properties
    end
    assert_equal(geom_collection.fetch(:properties), last_properties)
  end

  def test_flatten_each_multi_point
    feature_and_collection(multi_pt.fetch(:geometry)).each do |input|
      output = []
      Turf.flatten_each(input) do |feature|
        output.push(feature.fetch(:geometry))
      end
      assert_equal(
        [pt.fetch(:geometry), pt2.fetch(:geometry)],
        output,
      )
    end
  end

  def test_flatten_each_mixed_feature_collection
    feature_indexes = []
    multi_feature_indexes = []
    Turf.flatten_each(fc_mixed) do |_feature, feature_index, multi_feature_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
    end
    assert_equal([0, 1, 2, 2], feature_indexes)
    assert_equal([0, 0, 0, 1], multi_feature_indexes)
  end

  def test_flatten_each_point_properties
    collection(pt).each do |input|
      last_properties = nil
      Turf.flatten_each(input) do |feature|
        last_properties = feature.fetch(:properties)
      end
      assert_equal(pt.fetch(:properties), last_properties)
    end
  end

  def test_flatten_each_multi_geometry_properties
    collection(geom_collection).each do |input|
      last_properties = nil
      Turf.flatten_each(input) do |feature|
        last_properties = feature.fetch(:properties)
      end
      assert_equal(
        geom_collection.fetch(:properties),
        last_properties,
      )
    end
  end

  def test_flatten_reduce_initial_value
    last_index = nil
    last_sub_index = nil
    sum =
      Turf.flatten_reduce(
        multi_pt.fetch(:geometry), initial_value: 0
      ) do |previous, current, index, sub_index|
        last_index = index
        last_sub_index = sub_index
        return previous + current.fetch(:geometry).fetch(:coordinates)[0]
      end
    t.equal(last_index, 0)
    t.equal(last_sub_index, 1)
    t.equal(sum, 1)
    t.end
  end

  def test_flatten_reduce_previous_feature
    feature_indexes = []
    multi_feature_indexes = []
    Turf.flatten_reduce(
      multi_line,
    ) do |_previous, current, feature_index, multi_feature_index|
      feature_indexes.push(feature_index)
      multi_feature_indexes.push(multi_feature_index)
      current
    end
    assert_equal([0], feature_indexes)
    assert_equal([1], multi_feature_indexes)
  end

  # @see https://github.com/Turfjs/turf/issues/853
  def test_null_geometries_feature_each
    output = []
    Turf.feature_each fc_null do |feature|
      output.push feature.fetch(:geometry)
    end
    assert_equal([nil, nil], output)
  end

  def test_null_geometries_geom_each
    output = []
    Turf.geom_each fc_null do |geometry|
      output.push geometry
    end
    assert_equal([nil, nil], output)
  end

  def test_null_geometries_flatten_each
    output = []
    Turf.flatten_each fc_null do |feature|
      output.push feature.fetch(:geometry)
    end
    assert_equal([nil, nil], output)
  end

  def test_null_geometries_coord_each
    output = []
    Turf.coord_each fc_null do |coord|
      output.push coord
    end
    assert_equal([], output)
  end

  def test_null_geometries_feature_reduce
    assert_equal(
      2,
      Turf.feature_reduce(fc_null, initial_value: 0) { |prev| prev + 1 },
    )
  end

  def test_null_geometries_geom_reduce
    assert_equal(
      2,
      Turf.geom_reduce(fc_null, initial_value: 0) { |prev| prev + 1 },
    )
  end

  def test_null_geometries_flatten_reduce
    assert_equal(
      2,
      Turf.flatten_reduce(fc_null, initial_value: 0) { |prev| prev + 1 },
    )
  end

  def test_null_geometries_coord_reduce
    assert_equal(
      0,
      Turf.coord_reduce(fc_null, initial_value: 0) { |prev| prev + 1 },
    )
  end

  def test_null_geometries_index
    fc = Turf.feature_collection([
      Turf.feature(nil),
      Turf.point([0, 0]),
      Turf.feature(nil),
      Turf.line_string([
        [1, 1],
        [0, 0],
      ]),
    ])

    assert_equal(
      [0, 1, 2],
      Turf.coord_reduce(
        fc, initial_value: []
      ) { |prev, _cur, index| [*prev, index] },
    )

    assert_equal(
      [0, 1, 2, 3],
      Turf.geom_reduce(
        fc, initial_value: []
      ) { |prev, _cur, index| [*prev, index] },
    )

    assert_equal(
      [0, 1, 2, 3],
      Turf.flatten_reduce(
        fc, initial_value: []
      ) { |prev, _cur, index| [*prev, index] },
    )
  end
end
