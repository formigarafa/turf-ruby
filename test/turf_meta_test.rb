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
end
