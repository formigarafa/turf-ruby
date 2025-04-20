# frozen_string_literal: true

# :nodoc:
module Turf
  # Takes a bbox and returns an equivalent polygon.
  #
  # @param bbox [Array<Numeric>] extent in [minX, minY, maxX, maxY] order
  # @param options [Hash] Optional parameters
  # @option options [Hash] :properties Translate properties to Polygon
  # @option options [String, Numeric] :id Translate Id to Polygon
  # @return [Feature<Polygon>] a Polygon representation of the bounding box
  # @example
  # bbox = [0, 0, 10, 10]
  # poly = bbox_polygon(bbox)
  # # addToMap
  # add_to_map = [poly]
  def bbox_polygon(bbox, options = {})
    # Convert BBox positions to Numbers
    # No performance loss for including to_f
    # https://github.com/Turfjs/turf/issues/1119
    west = Float(bbox[0], exception: false) || Float::NAN
    south = Float(bbox[1], exception: false) || Float::NAN
    east = Float(bbox[2], exception: false) || Float::NAN
    north = Float(bbox[3], exception: false) || Float::NAN

    if bbox.length == 6
      raise Error, "@turf/bbox-polygon does not support BBox with 6 positions"
    end

    low_left = [west, south]
    top_left = [west, north]
    top_right = [east, north]
    low_right = [east, south]

    polygon(
      [[low_left, low_right, top_right, top_left, low_left]],
      options[:properties] || {},
      { bbox: bbox, id: options[:id] },
    )
  end
end
