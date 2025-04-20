# frozen_string_literal: true

# :nodoc:
module Turf
  # Takes a Feature and a bbox and clips the feature to the bbox using
  # [lineclip](https://github.com/mapbox/lineclip).
  # May result in degenerate edges when clipping Polygons.
  #
  # @param [Feature<LineString, MultiLineString, Polygon, MultiPolygon>, LineString, MultiLineString, Polygon, MultiPolygon] feature Feature to clip to the bbox
  # @param [BBox] bbox Extent in [minX, minY, maxX, maxY] order
  # @return [Feature<LineString, MultiLineString, Polygon, MultiPolygon>] Clipped Feature
  # @example
  #   bbox = [0, 0, 10, 10]
  #   poly = polygon([[[2, 2], [8, 4], [12, 8], [3, 7], [2, 2]]])
  #
  #   clipped = bbox_clip(poly, bbox)
  #
  #   # add_to_map
  #   add_to_map = [bbox, poly, clipped]
  def bbox_clip(feature, bbox)
    geom = get_geom(feature)
    type = geom[:type]
    properties = feature[:type] == "Feature" ? feature[:properties] : {}
    coords = geom[:coordinates]

    case type
    when "LineString", "MultiLineString"
      lines = []
      coords = [coords] if type == "LineString"

      coords.each do |line|
        Lineclip.lineclip(line, bbox, lines)
      end

      if lines.length == 1
        return line_string(lines[0], properties)
      end

      multi_line_string(lines, properties)
    when "Polygon"
      polygon(clip_polygon(coords, bbox), properties)
    when "MultiPolygon"
      multi_polygon(
        coords.map { |poly| clip_polygon(poly, bbox) },
        properties,
      )
    else
      raise Error, "geometry #{type} not supported"
    end
  end

  # Clips the rings of a Polygon or MultiPolygon to the bbox.
  #
  # @param [Array<Array<Array<Number>>>] rings The coordinates of the polygon rings
  # @param [BBox] bbox Extent in [minX, minY, maxX, maxY] order
  # @return [Array<Array<Array<Number>>>] Clipped polygon rings
  def clip_polygon(rings, bbox)
    out_rings = []

    rings.each do |ring|
      clipped = Lineclip.polygonclip(ring, bbox)

      next unless clipped.any?

      if clipped[0][0] != clipped[-1][0] || clipped[0][1] != clipped[-1][1]
        clipped.push(clipped[0])
      end

      out_rings.push(clipped) if clipped.length >= 4
    end

    out_rings
  end
end
