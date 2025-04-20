# frozen_string_literal: true

# :nodoc:
module Turf
  # Calculates the bounding box for any GeoJSON object, including FeatureCollection.
  # Uses geojson[:bbox] if available and options[:recompute] is not set.
  #
  # @param [Hash] geojson any GeoJSON object
  # @param [Hash] options optional parameters
  # @option options [Boolean] :recompute whether to ignore an existing bbox property on geojson
  # @return [Array<Float>] bbox extent in [minX, minY, maxX, maxY] order
  # @example
  #   line = {
  #     type: "LineString",
  #     coordinates: [[-74, 40], [-78, 42], [-82, 35]]
  #   }
  #   bbox = bbox(line)
  #   puts bbox.inspect # => [-82, 35, -74, 42]
  def bbox(geojson, options = {})
    # If geojson has a bbox property and options[:recompute] is not true, return the existing bbox
    return geojson[:bbox] if geojson[:bbox] && options[:recompute] != true

    # Initialize the result array with infinity values
    result = [Float::INFINITY, Float::INFINITY, -Float::INFINITY, -Float::INFINITY]

    # Iterate through each coordinate in the GeoJSON object using coord_each
    coord_each(geojson) do |coord|
      result[0] = coord[0] if result[0] > coord[0] # minX
      result[1] = coord[1] if result[1] > coord[1] # minY
      result[2] = coord[0] if result[2] < coord[0] # maxX
      result[3] = coord[1] if result[3] < coord[1] # maxY
    end

    result
  end
end
