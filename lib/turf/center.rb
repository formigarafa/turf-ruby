# frozen_string_literal: true

# :nodoc:
module Turf
  # frozen_string_literal: true

  # Takes a Feature or FeatureCollection and returns the absolute center point of all features.
  #
  # @param [GeoJSON] geojson GeoJSON to be centered
  # @param [Hash] options Optional parameters
  # @option options [Hash] :properties Translate GeoJSON Properties to Point
  # @option options [Array] :bbox Translate GeoJSON BBox to Point
  # @option options [String, Integer] :id Translate GeoJSON Id to Point
  # @return [Feature<Point>] a Point feature at the absolute center point of all input features
  # @example
  #   features = points([
  #     [-97.522259, 35.4691],
  #     [-97.502754, 35.463455],
  #     [-97.508269, 35.463245]
  #   ])
  #   center = center(features)
  #   # Add to map
  #   add_to_map = [features, center]
  #   center[:properties]['marker-size'] = 'large'
  #   center[:properties]['marker-color'] = '#000'
  def center(geojson, options = {})
    ext = bbox(geojson)
    x = (ext[0] + ext[2]) / 2.0
    y = (ext[1] + ext[3]) / 2.0
    point([x, y], options[:properties] || {}, options)
  end
end
