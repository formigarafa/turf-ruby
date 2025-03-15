# frozen_string_literal: true

require_relative "helpers"
require_relative "meta"

# :nodoc:
module Turf
  # Takes one or more features and returns their area in square meters.
  # @see https://turfjs.org/docs/#area
  # @param geojson [GeoJSON] input GeoJSON feature(s)
  # @return [number] aria in square meters
  def area(geojson)
    geom_reduce(geojson, initial_value: 0) do |value, geom|
      value + area_calculate_area(geom)
    end
  end

  AREA_RADIUS = 6_378_137.0

  private

  def area_calculate_area(geom)
    case geom[:type]
    when "Polygon"
      area_polygon_area(geom[:coordinates])
    when "MultiPolygon"
      geom[:coordinates].map do |coordinate|
        area_polygon_area(coordinate)
      end.sum
    else
      0
    end
  end

  def area_polygon_area(coords)
    outline, *holes = coords
    total = area_ring_area(outline).abs
    holes.each do |hole|
      total -= area_ring_area(hole).abs
    end
    total
  end

  def area_ring_area(coords)
    return 0 if coords.size <= 2

    total = 0

    coords.each_with_index do |_coord, index|
      lower_index, middle_index, upper_index =
        case index
        when coords.size - 2
          [
            coords.size - 2,
            coords.size - 1,
            0,
          ]
        when coords.size - 1
          [
            coords.size - 1,
            0,
            1,
          ]
        else
          [
            index,
            index + 1,
            index + 2,
          ]
        end
      p1 = coords[lower_index]
      p2 = coords[middle_index]
      p3 = coords[upper_index]
      total += (area_rad(p3[0]) - area_rad(p1[0])) * Math.sin(area_rad(p2[1]))
    end

    total * AREA_RADIUS * AREA_RADIUS / 2.0
  end

  def area_rad(num)
    num * Math::PI / 180.0
  end
end
