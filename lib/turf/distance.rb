# frozen_string_literal: true

require_relative "helpers"
require_relative "invariant"

# :nodoc:
module Turf
  # @!group Measurement

  # Calculates the distance between two points in degrees, radians, miles, or kilometers. This uses the Haversine
  # formula to account for global curvature.
  # @see http://turfjs.org/docs/#distance
  # @param from [Coord] origin point
  # @param to [Coord] destination point
  # @param units [string] can be degrees, radians, miles, or kilometers
  # @return [number] distance between the two points
  def distance(from, to, options = {})
    coordinates1 = get_coord from
    coordinates2 = get_coord to

    d_lat = degrees_to_radians coordinates2[1] - coordinates1[1]
    d_lon = degrees_to_radians coordinates2[0] - coordinates1[0]
    lat1 = degrees_to_radians coordinates1[1]
    lat2 = degrees_to_radians coordinates2[1]

    a =
      (
        (Math.sin(d_lat / 2.0)**2) +
        ((Math.sin(d_lon / 2.0)**2) * Math.cos(lat1) * Math.cos(lat2))
      )

    radians_to_length(
      2 * Math.atan2(
        Math.sqrt(a),
        Math.sqrt(1 - a),
      ),
      options[:units],
    )
  end
end
