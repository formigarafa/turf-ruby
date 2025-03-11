# frozen_string_literal: true

# :nodoc:
module Turf
  # @!group Measurement

  # Takes two points and finds the geographic bearing between them, i.e. the angle measured in degrees from the north
  # line (0 degrees)
  # @see http://turfjs.org/docs/#bearing
  # @param from [Coord] starting Point
  # @param to [Coord] ending Point
  # @param final boolean calculates the final bearing if true
  # @return [number] bearing in decimal degrees, between -180 and 180 degrees (positive clockwise)
  def bearing(from, to, final: false)
    return calculate_final_bearing(from, to) if final

    coordinates1 = get_coord from
    coordinates2 = get_coord to

    lon1 = degrees_to_radians(coordinates1[0])
    lon2 = degrees_to_radians(coordinates2[0])
    lat1 = degrees_to_radians(coordinates1[1])
    lat2 = degrees_to_radians(coordinates2[1])
    a = Math.sin(lon2 - lon1) * Math.cos(lat2)
    b = (Math.cos(lat1) * Math.sin(lat2)) -
        (Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1))

    radians_to_degrees(Math.atan2(a, b))
  end

  private

  def calculate_final_bearing(from, to)
    bear = bearing(to, from)
    (bear + 180) % 360
  end
end
