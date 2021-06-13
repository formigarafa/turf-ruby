# frozen_string_literal: true

module Turf
  # @!group Measurement

  # Takes a LineString and returns a Point at a specified distance along the line.
  # @see http://turfjs.org/docs/#along
  # @param line [Feature<LineString>] input line
  # @param distance [number] distance along the line
  # @param units [string] can be degrees, radians, miles, or kilometers (optional, default "kilometers")
  # @return [Feature<Point>] Point distance units along the line
  def along(line, distance, units: "kilometers")
    line = deep_symbolize_keys line
    travelled = 0

    geom = get_geom line
    coords = geom[:coordinates]

    coords.each_with_index do |coord, i|
      break if distance >= travelled && i == coords.length - 1

      if travelled >= distance
        overshot = distance - travelled
        return point(coord) if overshot.zero?

        direction = bearing(coord, coords[i - 1]) - 180
        interpolated = destination(coord, overshot, direction, units: units)
        return interpolated
      else
        travelled += distance(coords[i], coords[i + 1], units: units)
      end
    end

    point(coords.last)
  end
end
