# frozen_string_literal: true

require_relative "helpers"
require_relative "invariant"

# :nodoc:
module Turf
  # @!group Measurement

  # Takes a Point and calculates the location of a destination point given a distance in degrees, radians, miles, or
  # kilometers; and bearing in degrees. This uses the Haversine formula to account for global curvature.
  # @see http://turfjs.org/docs/#destination
  # @param origin [Coord] starting point
  # @param distance [number] distance from the origin point
  # @param bearing [number] ranging from -180 to 180
  # @param options[:units] [string] miles, kilometers, degrees, or radians
  # @param options[:properties] [Hash] Translate properties to Point
  # @return [Feature<Point>] destination point
  def destination(origin, distance, bearing, options = {})
    coordinates1 = get_coord origin
    longitude1 = degrees_to_radians coordinates1[0]
    latitude1 = degrees_to_radians coordinates1[1]
    bearing_radians = degrees_to_radians bearing
    radians = length_to_radians distance, options[:units]

    latitude2 = Math.asin((Math.sin(latitude1) * Math.cos(radians)) +
      (Math.cos(latitude1) * Math.sin(radians) * Math.cos(bearing_radians)))
    longitude2 = longitude1 + Math.atan2(
      Math.sin(bearing_radians) * Math.sin(radians) * Math.cos(latitude1),
      Math.cos(radians) - (Math.sin(latitude1) * Math.sin(latitude2)),
    )
    lng = radians_to_degrees(longitude2)
    lat = radians_to_degrees(latitude2)

    point([lng, lat], options[:properties])
  end
end
