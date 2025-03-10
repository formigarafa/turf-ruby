# frozen_string_literal: true

# :nodoc:
module Turf
  # Takes a Point and calculates the circle polygon given a radius in degrees, radians, miles, or kilometers;
  # and steps for precision.
  # @param {Feature<Point>|number[]} center center point
  # @param {number} radius radius of the circle
  # @param {hash} [options={}] Optional parameters
  # @param {number} [options.steps=64] number of steps
  # @param {string} [options.units='kilometers'] miles, kilometers, degrees, or radians
  # @param {hash} [options.properties={}] properties
  # @returns {Feature<Polygon>} circle polygon
  def circle(center, radius, options = {}, units: nil, steps: 64)
    # default params
    center = deep_symbolize_keys(center)
    properties = options[:properties] || (
      !center.is_a?(Array) && center[:type] == "Feature" && center[:properties] ? center[:properties] : {}
    )

    # main
    coordinates = []
    destination_options = { properties: properties }
    if units
      destination_options[:units] = units
    end
    steps.times do |i|
      coordinates.push(destination(center, radius, (i * -360.0) / steps, **options).dig(:geometry, :coordinates))
    end
    coordinates.push(coordinates[0])

    polygon([coordinates], properties: properties)
  end
end
