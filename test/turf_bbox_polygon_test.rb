# frozen_string_literal: true

require "test_helper"

class TurfBBoxPolygonTest < Minitest::Test
  def test_bbox_polygon
    bbox = [0, 0, 10, 10]
    poly = Turf.bbox_polygon(bbox)

    assert poly[:geometry][:coordinates], "should take a bbox and return the equivalent polygon feature"
    assert_equal "Polygon", poly[:geometry][:type], "should be a Polygon geometry type"
  end

  def test_bbox_polygon_valid_geojson
    bbox = [0, 0, 10, 10]
    poly = Turf.bbox_polygon(bbox)
    coordinates = poly[:geometry][:coordinates]

    assert poly, "should be valid geojson."
    assert_equal 5, coordinates[0].length
    assert_equal coordinates[0][0][0], coordinates[0][coordinates[0].length - 1][0]
    assert_equal coordinates[0][0][1], coordinates[0][coordinates[0].length - 1][1]
  end

  def test_bbox_polygon_handling_string_input_output
    bbox = %w[0 0 10 10]
    poly = Turf.bbox_polygon(bbox)

    assert_equal [0, 0], poly[:geometry][:coordinates][0][0], "lowLeft"
    assert_equal [10, 0], poly[:geometry][:coordinates][0][1], "lowRight"
    assert_equal [10, 10], poly[:geometry][:coordinates][0][2], "topRight"
    assert_equal [0, 10], poly[:geometry][:coordinates][0][3], "topLeft"
  end

  def test_bbox_polygon_error_handling
    assert_raises(Turf::Error, "6 position BBox not supported") do
      Turf.bbox_polygon([-110, 70, 5000, 50, 60, 3000])
    end

    assert_raises(Turf::Error, "invalid bbox") do
      Turf.bbox_polygon(%w[foo bar hello world])
    end

    assert_raises(Turf::Error, "invalid bbox") do
      Turf.bbox_polygon(%w[foo bar])
    end
  end

  def test_bbox_polygon_translate_bbox_issue_1179
    # bbox = [0, 0, 10, 10]
    # properties = { foo: "bar" }
    # id = 123
    # poly = Turf.bbox_polygon(bbox, properties: properties, id: id)
    #
    # assert_equal properties, poly.properties, "Properties is translated"
    # assert_equal bbox, poly.bbox, "BBox is translated"
    # assert_equal id, poly.id, "Id is translated"
  end

  def test_bbox_polygon_assert_bbox
    bbox = [0, 0, 10, 10]
    poly = Turf.bbox_polygon(bbox)

    assert_equal bbox, poly[:bbox]
  end
end
