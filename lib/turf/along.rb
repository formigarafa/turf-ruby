# frozen_string_literal: true

module Turf
  def self.along(line, distance, **options)
    travelled = 0

    geom = get_geom line
    coords = geom[:coordinates]

    coords.each_with_index do |coord, i|
      break if distance >= travelled && i == coords.length - 1

      if travelled >= distance
        overshot = distance - travelled
        return point(coord) if overshot.zero?

        direction = bearing(coord, coords[i - 1]) - 180
        interpolated = destination(coord, overshot, direction, **options)
        return interpolated
      else
        travelled += distance(coords[i], coords[i + 1], **options)
      end
    end

    point(coords.last)
  end
end
