# frozen_string_literal: true

require "test_helper"

class TurfBBoxTest < Minitest::Test
  def setup
    # Fixtures
    @pt = Turf.point([102.0, 0.5])
    @line = Turf.line_string([
      [102.0, -10.0],
      [103.0, 1.0],
      [104.0, 0.0],
      [130.0, 4.0],
    ])
    @poly = Turf.polygon([
      [
        [101.0, 0.0],
        [101.0, 1.0],
        [100.0, 1.0],
        [100.0, 0.0],
        [101.0, 0.0],
      ],
    ])
    @multi_line = Turf.multi_line_string([
      [
        [100.0, 0.0],
        [101.0, 1.0],
      ],
      [
        [102.0, 2.0],
        [103.0, 3.0],
      ],
    ])
    @multi_poly = Turf.multi_polygon([
      [
        [
          [102.0, 2.0],
          [103.0, 2.0],
          [103.0, 3.0],
          [102.0, 3.0],
          [102.0, 2.0],
        ],
      ],
      [
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
      ],
    ])
    @fc = Turf.feature_collection([@pt, @line, @poly, @multi_line, @multi_poly])
  end

  def test_bbox
    # FeatureCollection
    assert_equal [100, -10, 130, 4], Turf.bbox(@fc), "featureCollection"

    # Point
    assert_equal [102, 0.5, 102, 0.5], Turf.bbox(@pt), "point"

    # LineString
    assert_equal [102, -10, 130, 4], Turf.bbox(@line), "lineString"

    # Polygon
    assert_equal [100, 0, 101, 1], Turf.bbox(@poly), "polygon"

    # MultiLineString
    assert_equal [100, 0, 103, 3], Turf.bbox(@multi_line), "multiLineString"

    # MultiPolygon
    assert_equal [100, 0, 103, 3], Turf.bbox(@multi_poly), "multiPolygon"

    # Built-in bbox
    assert_equal [], Turf.bbox(@pt.merge(bbox: [])), "uses built-in bbox by default"

    # Recompute bbox
    assert_equal [102, 0.5, 102, 0.5], Turf.bbox(@pt.merge(bbox: []), recompute: true),
                 "recomputes bbox with recompute option"
  end

  def test_bbox_throws
    assert_raises_with_message(Turf::Error, "Unknown Geometry Type") do
      Turf.bbox({})
    end
  end

  def test_bbox_null_geometries
    assert_equal [Float::INFINITY, Float::INFINITY, -Float::INFINITY, -Float::INFINITY],
                 Turf.bbox(Turf.feature(nil))
  end
end
