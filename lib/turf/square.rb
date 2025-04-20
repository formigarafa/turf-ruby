# frozen_string_literal: true

# :nodoc:
module Turf
  # frozen_string_literal: true

  # Takes a bounding box and calculates the minimum square bounding box that
  # would contain the input.
  #
  # @param [Array<Float>] bbox extent in [west, south, east, north] order
  # @return [Array<Float>] a square surrounding `bbox`
  # @example
  #   bbox = [-20, -20, -15, 0]
  #   squared = square(bbox)
  #
  #   #addToMap
  #   # add_to_map = [bbox_polygon(bbox), bbox_polygon(squared)]
  def square(bbox)
    west, south, east, north = bbox

    horizontal_distance = distance([west, south], [east, south])
    vertical_distance = distance([west, south], [west, north])

    if horizontal_distance >= vertical_distance
      vertical_midpoint = (south + north) / 2.0
      [
        west,
        vertical_midpoint - ((east - west) / 2.0),
        east,
        vertical_midpoint + ((east - west) / 2.0),
      ]
    else
      horizontal_midpoint = (west + east) / 2.0
      [
        horizontal_midpoint - ((north - south) / 2.0),
        south,
        horizontal_midpoint + ((north - south) / 2.0),
        north,
      ]
    end
  end
end
