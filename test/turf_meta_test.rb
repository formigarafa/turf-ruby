# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-meta/test.js
class TurfMetaTest < Minitest::Test
  def pt
    Turf.point([0, 0], { a: 1 })
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
      { a: 0 },
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

  def geojson_segments
    Turf.feature_collection(
      [
        Turf.point([0, 1]), # ignored
        Turf.line_string([
          [0, 0],
          [2, 2],
          [4, 4],
        ]),
        Turf.polygon([
          [
            [5, 5],
            [0, 0],
            [2, 2],
            [4, 4],
            [5, 5],
          ],
        ]),
        Turf.point([0, 1]), # ignored
        Turf.multi_line_string([
          [
            [0, 0],
            [2, 2],
            [4, 4],
          ],
          [
            [0, 0],
            [2, 2],
            [4, 4],
          ],
        ]),
      ],
    )
  end

  def test_prop_each
    props = []
    collection(pt).each do |input|
      Turf.prop_each(input) do |prop, _i|
        props << prop
      end
    end
    assert_equal([{ a: 1 }, { a: 1 }], props)
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
    coords = []
    coord_indexes = []
    feature_indexes = []
    multi_feature_indexes = []
    Turf.coord_each multi_poly do |coord, coord_index, feature_index, multi_feature_index|
      coords.push coord
      coord_indexes.push coord_index
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
    end
    assert_equal(coord_indexes, [0, 1, 2, 3, 4, 5, 6, 7])
    assert_equal(feature_indexes, [0, 0, 0, 0, 0, 0, 0, 0])
    assert_equal(multi_feature_indexes, [0, 0, 0, 0, 1, 1, 1, 1])
    assert_equal(coords.length, 8)
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
      0,
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

  def test_array_reduce_initial_value
    last_index = nil
    line = [
      [126, -11],
      [129, -21],
      [135, -31],
    ]
    sum = line.each_with_index.reduce(0) do |previous, (current_coords, index)|
      last_index = index
      previous + current_coords[0]
    end
    assert_equal(2, last_index)
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

  def test_array_reduce_previous_coordinates
    last_index = nil
    coords = []
    line[:geometry][:coordinates].each_with_index.reduce(nil) do |_previous_coords, (current_coords, index)|
      last_index = index
      coords.push(current_coords)
      current_coords.reverse
    end
    assert_equal(1, last_index)
    assert_equal(2, coords.length)
  end

  def test_coord_reduce_previous_coordinates_initial_value
    output = []
    Turf.coord_reduce(
      line,
      line.fetch(:geometry).fetch(:coordinates)[0],
    ) do |previous, coords, index|
      output.push [previous, coords, index]
      coords
    end

    assert_equal([
      [[0, 0], [0, 0], 0],
      [[0, 0], [1, 1], 1],
    ], output)
  end

  def test_array_reduce_previous_coordinates_initial_value
  end

  def test_unknown
    assert_raises_with_message(Turf::Error, "Unknown Geometry Type") do
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
    sum = Turf.flatten_reduce(
      multi_pt.fetch(:geometry), 0
    ) do |previous, current, index, sub_index|
      last_index = index
      last_sub_index = sub_index
      previous + current.fetch(:geometry).fetch(:coordinates)[0]
    end
    assert_equal(last_index, 0)
    assert_equal(last_sub_index, 1)
    assert_equal(sum, 1)
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

  def test_flatten_reduce_previous_feature_initial_value
    last_index = nil
    last_sub_index = nil
    sum = Turf.flatten_reduce(multi_pt[:geometry], 0) do |previous, current, index, sub_index|
      last_index = index
      last_sub_index = sub_index
      previous + current[:geometry][:coordinates][0]
    end
    assert_equal(0, last_index)
    assert_equal(1, last_sub_index)
    assert_equal(1, sum)
  end

  # @see https://github.com/Turfjs/turf/issues/853
  def test_null_geometries
    output = []
    Turf.feature_each fc_null do |feature|
      output.push feature.fetch(:geometry)
    end
    assert_equal([nil, nil], output, "feature_each")

    output = []
    Turf.geom_each fc_null do |geometry|
      output.push geometry
    end
    assert_equal([nil, nil], output, "geom_each")

    output = []
    Turf.flatten_each fc_null do |feature|
      output.push feature.fetch(:geometry)
    end
    assert_equal([nil, nil], output, "flatten_each")

    Turf.coord_each(fc_null) { |_coord| raise("no coordinate should be found") }

    assert_equal(
      2,
      Turf.feature_reduce(fc_null, 0) { |prev| prev + 1 },
      "feature_reduce",
    )

    assert_equal(
      2,
      Turf.geom_reduce(fc_null, 0) { |prev| prev + 1 },
      "geom_reduce",
    )

    assert_equal(
      2,
      Turf.flatten_reduce(fc_null, 0) { |prev| prev + 1 },
      "flatten_reduce",
    )

    assert_equal(
      0,
      Turf.coord_reduce(fc_null, 0) { |prev| prev + 1 },
      "coord_reduce",
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
        fc, []
      ) { |prev, _cur, index| [*prev, index] },
    )

    assert_equal(
      [0, 1, 2, 3],
      Turf.geom_reduce(
        fc, []
      ) { |prev, _cur, index| [*prev, index] },
    )

    assert_equal(
      [0, 1, 2, 3],
      Turf.flatten_reduce(
        fc, []
      ) { |prev, _cur, index| [*prev, index] },
    )
  end

  def test_segment_each
    segments = []
    total = 0
    Turf.segment_each(poly[:geometry]) do |current_segment|
      segments.push(current_segment)
      total += 1
    end
    assert_equal(2, segments[0][:geometry][:coordinates].length)
    assert_equal(3, total)
  end

  def test_segment_each_multi_point
    segments = []
    total = 0
    Turf.segment_each(multi_pt[:geometry]) do |current_segment|
      segments.push(current_segment)
      total += 1
    end
    assert_equal(0, total) # No segments are created from MultiPoint geometry
  end

  def test_segment_reduce
    segments = []
    total = Turf.segment_reduce(poly[:geometry], 0) do |previous_value, current_segment|
      segments.push(current_segment)
      previous_value += 1
      previous_value
    end
    assert_equal(2, segments[0][:geometry][:coordinates].length)
    assert_equal(3, total)
  end

  def test_segment_reduce_no_initial_value
    segments = []
    total = 0
    Turf.segment_reduce(poly[:geometry]) do |_previous_value, current_segment|
      segments.push(current_segment)
      total += 1
    end
    assert_equal(2, segments[0][:geometry][:coordinates].length)
    assert_equal(2, total)
  end

  def test_segment_each_index_and_sub_index
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    segment_indexes = []
    total = 0

    Turf.segment_each(geojson_segments) do |_segment, feature_index, multi_feature_index, geometry_index, segment_index|
      feature_indexes.push(feature_index)
      multi_feature_indexes.push(multi_feature_index)
      geometry_indexes.push(geometry_index)
      segment_indexes.push(segment_index)
      total += 1
    end
    assert_equal(10, total, "total")
    assert_equal(
      [1, 1, 2, 2, 2, 2, 4, 4, 4, 4],
      feature_indexes,
      "segmentEach.feature_index",
    )
    assert_equal(
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      multi_feature_indexes,
      "segmentEach.multi_feature_index",
    )
    assert_equal(
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      geometry_indexes,
      "segmentEach.geometry_index",
    )
    assert_equal(
      [0, 1, 0, 1, 2, 3, 0, 1, 0, 1],
      segment_indexes,
      "segmentEach.segment_index",
    )
  end

  def test_segment_reduce_index_and_sub_index
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    segment_indexes = []
    total = 0

    Turf.segment_reduce(geojson_segments) do |
      _previous_value,
      _segment,
      feature_index,
      multi_feature_index,
      geometry_index,
      segment_index
    |
      feature_indexes.push(feature_index)
      multi_feature_indexes.push(multi_feature_index)
      geometry_indexes.push(geometry_index)
      segment_indexes.push(segment_index)
      total += 1
    end

    assert_equal(total, 9, "total")
    assert_equal(
      [1, 2, 2, 2, 2, 4, 4, 4, 4],
      feature_indexes,
      "segmentReduce.feature_index",
    )
    assert_equal(
      [0, 0, 0, 0, 0, 0, 0, 1, 1],
      multi_feature_indexes,
      "segmentReduce.multi_feature_index",
    )
    assert_equal(
      [0, 0, 0, 0, 0, 0, 0, 0, 0],
      geometry_indexes,
      "segmentReduce.geometry_index",
    )
    assert_equal(
      [1, 0, 1, 2, 3, 0, 1, 0, 1],
      segment_indexes,
      "segmentReduce.segment_index",
    )
  end

  def test_line_each_line_string
    line = Turf.line_string([
      [0, 0],
      [2, 2],
      [4, 4],
    ])
    feature_indexes = []
    multi_feature_indexes = []
    line_indexes = []
    total = 0

    Turf.line_each(
      line,
    ) do |_current_line, feature_index, multi_feature_index, line_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
      line_indexes.push line_index
      total += 1
    end
    assert_equal(1, total)
    assert_equal([0], feature_indexes)
    assert_equal([0], multi_feature_indexes)
    assert_equal([0], line_indexes)
  end

  def test_line_each_multi_line_string
    multi_line = Turf.multi_line_string([
      [
        [0, 0],
        [2, 2],
        [4, 4],
      ],
      [
        [1, 1],
        [3, 3],
        [5, 5],
      ],
    ])
    feature_indexes = []
    multi_feature_indexes = []
    line_indexes = []
    total = 0

    Turf.line_each(
      multi_line,
    ) do |_current_line, feature_index, multi_feature_index, line_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
      line_indexes.push line_index
      total += 1
    end
    assert_equal(2, total)
    assert_equal([0, 0], feature_indexes)
    assert_equal([0, 1], multi_feature_indexes)
    assert_equal([0, 0], line_indexes)
  end

  def test_line_each_multi_polygon
    multi_poly = Turf.multi_polygon([
      [
        [
          [12, 48],
          [2, 41],
          [24, 38],
          [12, 48],
        ],
        [
          [9, 44],
          [13, 41],
          [13, 45],
          [9, 44],
        ],
      ],
      [
        [
          [5, 5],
          [0, 0],
          [2, 2],
          [4, 4],
          [5, 5],
        ],
      ],
    ])
    feature_indexes = []
    multi_feature_indexes = []
    line_indexes = []
    total = 0

    Turf.line_each(
      multi_poly,
    ) do |_current_line, feature_index, multi_feature_index, line_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
      line_indexes.push line_index
      total += 1
    end
    assert_equal(3, total)
    assert_equal([0, 0, 0], feature_indexes)
    assert_equal([0, 0, 1], multi_feature_indexes)
    assert_equal([0, 1, 0], line_indexes)
  end

  def test_line_each_feature_collection
    line = Turf.line_string([
      [0, 0],
      [2, 2],
      [4, 4],
    ])
    multi_line = Turf.multi_line_string([
      [
        [0, 0],
        [2, 2],
        [4, 4],
      ],
      [
        [1, 1],
        [3, 3],
        [5, 5],
      ],
    ])
    multi_poly = Turf.multi_polygon([
      [
        [
          [12, 48],
          [2, 41],
          [24, 38],
          [12, 48],
        ],
        [
          [9, 44],
          [13, 41],
          [13, 45],
          [9, 44],
        ],
      ],
      [
        [
          [5, 5],
          [0, 0],
          [2, 2],
          [4, 4],
          [5, 5],
        ],
      ],
    ])
    feature_indexes = []
    multi_feature_indexes = []
    line_indexes = []
    total = 0

    Turf.line_each(
      Turf.feature_collection([line, multi_line, multi_poly]),
    ) do |_current_line, feature_index, multi_feature_index, line_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
      line_indexes.push line_index
      total += 1
    end
    assert_equal(6, total)
    assert_equal([0, 1, 1, 2, 2, 2], feature_indexes)
    assert_equal([0, 0, 1, 0, 0, 1], multi_feature_indexes)
    assert_equal([0, 0, 0, 0, 1, 0], line_indexes)
  end

  def test_line_reduce_multi_line_string
    multi_line = Turf.multi_line_string([
      [
        [0, 0],
        [2, 2],
        [4, 4],
      ],
      [
        [1, 1],
        [3, 3],
        [5, 5],
      ],
    ])

    total = Turf.line_reduce(multi_line, 0) do |previous|
      previous + 1
    end
    assert_equal(2, total)
  end

  def test_line_reduce_multi_polygon
    multi_poly = Turf.multi_polygon([
      [
        [
          [12, 48],
          [2, 41],
          [24, 38],
          [12, 48],
        ], # outer
        [
          [9, 44],
          [13, 41],
          [13, 45],
          [9, 44],
        ],
      ], # inner
      [
        [
          [5, 5],
          [0, 0],
          [2, 2],
          [4, 4],
          [5, 5],
        ], # outer
      ],
    ])

    total = Turf.line_reduce(multi_poly, 0) do |previous|
      previous + 1
    end
    assert_equal(3, total)
  end

  def test_line_each_and_line_reduce_assert
    pt = Turf.point([0, 0])
    multi_pt = Turf.multi_point([
      [0, 0],
      [10, 10],
    ])
    noop = ->(*_args) {}

    Turf.line_each(pt, &noop) # Point geometry is supported
    Turf.line_each(multi_pt, &noop) # MultiPoint geometry is supported
    Turf.line_reduce(pt, &noop) # Point geometry is supported
    Turf.line_reduce(multi_pt, &noop) # MultiPoint geometry is supported
    Turf.line_reduce(geom_collection, &noop) # GeometryCollection is supported
    Turf.line_reduce(
      Turf.feature_collection([
        Turf.line_string([
          [10, 10],
          [0, 0],
        ]),
      ]), &noop
    ) # FeatureCollection is supported
    Turf.line_reduce(Turf.feature(nil), &noop) # Feature with null geometry is supported
  end

  def test_geom_each_callback_bbox_and_id
    properties = { foo: "bar" }
    bbox = [0, 0, 0, 0]
    id = "foo"
    pt = Turf.point([0, 0], properties, bbox: bbox, id: id)

    Turf.geom_each(
      pt,
    ) do |_current_geometry, feature_index, current_properties, current_bbox, current_id|
      assert_equal(0, feature_index)
      assert_equal(properties, current_properties)
      assert_equal(bbox, current_bbox)
      assert_equal(id, current_id)
    end
  end

  def test_line_each_callback_bbox_and_id
    properties = { foo: "bar" }
    bbox = [0, 0, 10, 10]
    id = "foo"
    line = Turf.line_string(
      [
        [0, 0],
        [10, 10],
      ],
      properties,
      bbox: bbox,
      id: id,
    )

    Turf.line_each(line) do |current_line|
      assert_equal(line, current_line)
    end
  end

  def test_line_each_return_line_string
    properties = { foo: "bar" }
    bbox = [0, 0, 10, 10]
    id = "foo"
    line = Turf.line_string(
      [
        [0, 0],
        [10, 10],
      ],
      properties,
      bbox: bbox,
      id: id,
    )

    Turf.line_each(line) do |current_line|
      assert_equal(line, current_line)
    end
  end

  def test_coord_each_indexes_polygon_with_hole
    coord_indexes = []
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []

    Turf.coord_each(poly_with_hole) do |_coords, coord_index, feature_index, multi_feature_index, geometry_index|
      coord_indexes.push(coord_index)
      feature_indexes.push(feature_index)
      multi_feature_indexes.push(multi_feature_index)
      geometry_indexes.push(geometry_index)
    end
    assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], coord_indexes)
    assert_equal([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], feature_indexes)
    assert_equal([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multi_feature_indexes)
    assert_equal([0, 0, 0, 0, 0, 1, 1, 1, 1, 1], geometry_indexes)
  end

  # (source line: 1081)
  def test_line_each_indexes_polygon_with_hole
    poly_with_hole = Turf.polygon([
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
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []

    Turf.line_each(
      poly_with_hole,
    ) do |_current_line, feature_index, multi_feature_index, geometry_index|
      feature_indexes.push feature_index
      multi_feature_indexes.push multi_feature_index
      geometry_indexes.push geometry_index
    end
    assert_equal([0, 0], feature_indexes)
    assert_equal([0, 0], multi_feature_indexes)
    assert_equal([0, 1], geometry_indexes)
  end

  def test_segment_each_indexes_polygon_with_hole
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    segment_indexes = []

    Turf.segment_each(poly_with_hole) do |_segment, feature_index, multi_feature_index, geometry_index, segment_index|
      feature_indexes.push(feature_index)
      multi_feature_indexes.push(multi_feature_index)
      geometry_indexes.push(geometry_index)
      segment_indexes.push(segment_index)
    end

    assert_equal([0, 0, 0, 0, 0, 0, 0, 0], feature_indexes)
    assert_equal([0, 0, 0, 0, 0, 0, 0, 0], multi_feature_indexes)
    assert_equal([0, 0, 0, 0, 1, 1, 1, 1], geometry_indexes)
    assert_equal([0, 1, 2, 3, 0, 1, 2, 3], segment_indexes)
  end

  def test_coord_each_indexes_multi_polygon_with_hole
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    coord_indexes = []

    # MultiPolygon with hole
    # ======================
    # FeatureIndex => 0
    multi_poly_with_hole = Turf.multi_polygon([
      # Polygon 1
      # ---------
      # MultiFeature Index => 0
      [
        # Outer Ring
        # ----------
        # Geometry Index => 0
        # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
        [
          [102.0, 2.0],
          [103.0, 2.0],
          [103.0, 3.0],
          [102.0, 3.0],
          [102.0, 2.0],
        ],
      ],
      # Polygon 2 with Hole
      # -------------------
      # MultiFeature Index => 1
      [
        # Outer Ring
        # ----------
        # Geometry Index => 0
        # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
        [
          [100.0, 0.0],
          [101.0, 0.0],
          [101.0, 1.0],
          [100.0, 1.0],
          [100.0, 0.0],
        ],
        # Inner Ring
        # ----------
        # Geometry Index => 1
        # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
        [
          [100.2, 0.2],
          [100.8, 0.2],
          [100.8, 0.8],
          [100.2, 0.8],
          [100.2, 0.2],
        ],
      ],
    ])

    Turf.coord_each(multi_poly_with_hole) do |_coord, coord_index, feature_index, multi_feature_index, geometry_index|
      feature_indexes << feature_index
      multi_feature_indexes << multi_feature_index
      geometry_indexes << geometry_index
      coord_indexes << coord_index
    end

    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], feature_indexes
    assert_equal [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], multi_feature_indexes
    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1], geometry_indexes
    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], coord_indexes
    # Major Release Change v6.x
    # assert_equal [0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4], coord_indexes
  end

  # (source line: 1223)
  def test_coord_each_indexes_polygon_with_hole2
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    coord_indexes = []

    # Polygon with Hole
    # =================
    # Feature Index => 0
    poly_with_hole = Turf.polygon([
      # Outer Ring
      # ----------
      # Geometry Index => 0
      # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
      [
        [100.0, 0.0],
        [101.0, 0.0],
        [101.0, 1.0],
        [100.0, 1.0],
        [100.0, 0.0],
      ],
      # Inner Ring
      # ----------
      # Geometry Index => 1
      # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
      [
        [100.2, 0.2],
        [100.8, 0.2],
        [100.8, 0.8],
        [100.2, 0.8],
        [100.2, 0.2],
      ],
    ])

    Turf.coord_each(poly_with_hole) do |_coord, coord_index, feature_index, multi_feature_index, geometry_index|
      feature_indexes << feature_index
      multi_feature_indexes << multi_feature_index
      geometry_indexes << geometry_index
      coord_indexes << coord_index
    end

    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], feature_indexes
    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multi_feature_indexes
    assert_equal [0, 0, 0, 0, 0, 1, 1, 1, 1, 1], geometry_indexes
    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], coord_indexes
    # Major Release Change v6.x
    # assert_equal [0, 1, 2, 3, 4, 0, 1, 2, 3, 4], coord_indexes
  end

  def test_coord_each_indexes_feature_collection_of_line_string
    feature_indexes = []
    multi_feature_indexes = []
    geometry_indexes = []
    coord_indexes = []

    # FeatureCollection of LineStrings
    line = Turf.line_strings([
      # LineString 1
      # Feature Index => 0
      # Geometry Index => 0
      # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
      [
        [100.0, 0.0],
        [101.0, 0.0],
        [101.0, 1.0],
        [100.0, 1.0],
        [100.0, 0.0],
      ],
      # LineString 2
      # Feature Index => 1
      # Geometry Index => 0
      # Coord Index => [0, 1, 2, 3, 4] (Major Release Change v6.x)
      [
        [100.2, 0.2],
        [100.8, 0.2],
        [100.8, 0.8],
        [100.2, 0.8],
        [100.2, 0.2],
      ],
    ])

    Turf.coord_each(line) do |_coord, coord_index, feature_index, multi_feature_index, geometry_index|
      feature_indexes << feature_index
      multi_feature_indexes << multi_feature_index
      geometry_indexes << geometry_index
      coord_indexes << coord_index
    end

    assert_equal [0, 0, 0, 0, 0, 1, 1, 1, 1, 1], feature_indexes
    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], multi_feature_indexes
    assert_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], geometry_indexes
    assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], coord_indexes
    # Major Release Change v6.x
    # assert_equal [0, 1, 2, 3, 4, 0, 1, 2, 3, 4], coord_indexes
  end

  def test_breaking_of_iterations
    lines = Turf.line_strings([
      [
        [10, 10],
        [50, 30],
        [30, 40],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
      ],
    ])
    multi_line = Turf.multi_line_string([
      [
        [10, 10],
        [50, 30],
        [30, 40],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
      ],
    ])

    # Each Iterators
    # meta.segment_each has been purposely excluded from this list
    tested_functions = 0
    %i[
      coord_each
      feature_each
      flatten_each
      geom_each
      line_each
      prop_each
      segment_each
    ].each do |func_name|
      # Meta Each function should only a value of 1 after returning `false`

      # FeatureCollection
      count = 0
      Turf.send(func_name, lines) do
        count += 1
        break false
      end
      assert_equal(1, count, func_name)

      # Multi Geometry
      multi_count = 0
      Turf.send(func_name, multi_line) do
        multi_count += 1
        break false
      end
      assert_equal(1, multi_count, func_name)
      tested_functions += 1
    end
    assert_equal(7, tested_functions)
  end

  def test_test_find_segment
    null_feature = Turf.feature(nil)
    pt = Turf.point([10, 10])
    line = Turf.line_string([
      [10, 10],
      [50, 30],
      [30, 40],
    ])
    poly = Turf.polygon([
      [
        [10, 10],
        [50, 30],
        [30, 40],
        [10, 10],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
        [-10, -10],
      ],
    ])
    multi_line = Turf.multi_line_string([
      [
        [10, 10],
        [50, 30],
        [30, 40],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
      ],
    ])
    lines = Turf.line_strings([
      [
        [10, 10],
        [50, 30],
        [30, 40],
        [10, 10],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
        [-10, -10],
      ],
    ])

    # firstSegment
    assert_nil(Turf.find_segment(null_feature))
    assert_nil(Turf.find_segment(pt))
    assert_equal(
      Turf.line_string([
        [10, 10],
        [50, 30],
      ]),
      Turf.find_segment(line),
    )
    assert_equal(
      Turf.line_string([
        [10, 10],
        [50, 30],
      ]),
      Turf.find_segment(poly),
    )
    assert_equal(
      Turf.line_string([
        [10, 10],
        [50, 30],
      ]),
      Turf.find_segment(multi_line),
    )
    assert_equal(
      Turf.line_string([
        [10, 10],
        [50, 30],
      ]),
      Turf.find_segment(lines),
    )

    # lastSegment
    assert_nil(Turf.find_segment(null_feature))
    assert_nil(Turf.find_segment(pt))
    assert_equal(
      Turf.line_string([
        [50, 30],
        [30, 40],
      ]),
      Turf.find_segment(line, segment_index: -1),
    )
    assert_equal(
      Turf.line_string([
        [-30, -40],
        [-10, -10],
      ]),
      Turf.find_segment(poly, segment_index: -1, geometry_index: -1),
    )
    assert_equal(
      Turf.line_string([
        [-50, -30],
        [-30, -40],
      ]),
      Turf.find_segment(multi_line, segment_index: -1, multi_feature_index: -1),
    )
    assert_equal(
      Turf.line_string([
        [-30, -40],
        [-10, -10],
      ]),
      Turf.find_segment(lines, segment_index: -1, feature_index: -1),
    )
  end

  def test_find_point
    null_feature = Turf.feature(nil)
    pt = Turf.point([10, 10])
    line = Turf.line_string([
      [10, 10],
      [50, 30],
      [30, 40],
    ])
    poly = Turf.polygon([
      [
        [10, 10],
        [50, 30],
        [30, 40],
        [10, 10],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
        [-10, -10],
      ],
    ])
    multi_line = Turf.multi_line_string([
      [
        [10, 10],
        [50, 30],
        [30, 40],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
      ],
    ])
    lines = Turf.line_strings([
      [
        [10, 10],
        [50, 30],
        [30, 40],
        [10, 10],
      ],
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
        [-10, -10],
      ],
    ])

    # firstPoint
    assert_nil(Turf.find_point(null_feature))
    assert_equal(Turf.point([10, 10]), Turf.find_point(pt))
    assert_equal(Turf.point([10, 10]), Turf.find_point(line))
    assert_equal(Turf.point([10, 10]), Turf.find_point(poly))
    assert_equal(Turf.point([10, 10]), Turf.find_point(multi_line))
    assert_equal(Turf.point([10, 10]), Turf.find_point(lines))

    # lastPoint
    assert_nil(Turf.find_point(null_feature))
    assert_equal(Turf.point([10, 10]), Turf.find_point(pt))
    assert_equal(
      Turf.point([30, 40]),
      Turf.find_point(line, coord_index: -1),
    )
    assert_equal(
      Turf.point([-10, -10]),
      Turf.find_point(poly, coord_index: -1, geometry_index: -1),
    )
    assert_equal(
      Turf.point([-30, -40]),
      Turf.find_point(multi_line, coord_index: -1, multi_feature_index: -1),
    )
    assert_equal(
      Turf.point([-10, -10]),
      Turf.find_point(lines, coord_index: -1, feature_index: -1),
    )
  end

  def test_segment_each_issue_1273
    # https://github.com/Turfjs/turf/issues/1273
    poly = Turf.polygon([
      # Outer Ring
      # Segment = 0
      # Geometries = 0,1,2
      [
        [10, 10],
        [50, 30],
        [30, 40],
        [10, 10],
      ],
      # Inner Ring
      # Segment => 1
      # Geometries => 0,1,2
      [
        [-10, -10],
        [-50, -30],
        [-30, -40],
        [-10, -10],
      ],
    ])
    segment_indexes = []
    geometry_indexes = []
    Turf.segment_each(
      poly,
    ) do |_line, _feature_index, _multi_feature_index, segment_index, geometry_index|
      segment_indexes.push segment_index
      geometry_indexes.push geometry_index
    end
    assert_equal([0, 0, 0, 1, 1, 1], segment_indexes)
    assert_equal([0, 1, 2, 0, 1, 2], geometry_indexes)
  end
end
