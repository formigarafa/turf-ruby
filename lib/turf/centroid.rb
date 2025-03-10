# frozen_string_literal: true

#:nodoc:
module Turf
  # @!group Measurement

  # Takes one or more features and calculates the centroid using the mean of all vertices. This lessens the effect of
  # small islands and artifacts when calculating the centroid of a set of polygons.
  # @see http://turfjs.org/docs/#centroid
  # @param geojson [GeoJSON] GeoJSON to be centered
  # @param properties [Hash] a [Hash] that is used as the Feature's properties
  # @return [Feature<Point>] the centroid of the input features
  def centroid(geojson, properties: {})
    x_sum = 0.0
    y_sum = 0.0
    len = 0.0

    coord_each geojson, exclude_wrap_coord: true do |coord|
      x_sum += coord[0]
      y_sum += coord[1]
      len += 1
    end

    point(
      [x_sum / len, y_sum / len],
      properties: properties,
    )
  end
end
