# frozen_string_literal: true

#:nodoc:
module Turf
  # @!group Booleans

  # Takes a Point and a Polygon or MultiPolygon and determines if the point resides inside the polygon. The polygon
  # can be convex or concave. The function accounts for holes.
  # @see http://turfjs.org/docs/#booleanPointInPolygon
  # @param point [Coord] input point
  # @param polygon [Feature<(Polygon | MultiPolygon)>] input polygon or multipolygon
  # @param ignore_boundary [boolean] True if polygon boundary should be ignored when determining if the point is
  # inside
  # the polygon otherwise false.
  # @return [boolean] true if the Point is inside the Polygon; false if the Point is not inside the Polygon
  def boolean_point_in_polygon(point, polygon, ignore_boundary: false)
    polygon = deep_symbolize_keys(polygon)
    pt = get_coord(point)
    geom = get_geom(polygon)
    type = geom.fetch(:type)
    bbox = polygon[:bbox]
    polys = geom.fetch(:coordinates)

    # Quick elimination if point is not inside bbox
    return false if bbox && !in_bbox(pt, bbox)

    # normalize to multipolygon
    polys = [polys] if type == "Polygon"

    inside_poly = false
    polys.each do |poly|
      # check if it is in the outer ring first
      next unless in_ring(pt, poly[0], ignore_boundary)

      in_hole = false

      # check for the point in any of the holes
      poly.slice(1, poly.size - 1).each do |hole|
        if in_ring(pt, hole, !ignore_boundary)
          in_hole = true
        end
      end
      if !in_hole
        inside_poly = true
      end
    end
    inside_poly
  end

  private

  def in_bbox(point, bbox)
    bbox[0] <= point[0] &&
      bbox[1] <= point[1] &&
      bbox[2] >= point[0] &&
      bbox[3] >= point[1]
  end

  def in_ring(point, ring, ignore_boundary)
    is_inside = false
    is_ring_valid = ring[0][0] == ring[ring.size - 1][0]
    is_ring_valid &&= ring[0][1] == ring[ring.size - 1][1]
    if is_ring_valid
      ring = ring.slice(0, ring.size - 1)
    end
    ring.each_with_index do |ring_pt, ring_pt_index|
      ring_pt2 = ring[(ring_pt_index + 1) % ring.size]

      xi = ring_pt[0]
      yi = ring_pt[1]
      xj = ring_pt2[0]
      yj = ring_pt2[1]

      on_boundary = (
        point[1] * (xi - xj) + yi * (xj - point[0]) + yj * (point[0] - xi)
      ).zero?
      on_boundary &&= ((xi - point[0]) * (xj - point[0]) <= 0)
      on_boundary &&= ((yi - point[1]) * (yj - point[1]) <= 0)
      if on_boundary
        return !ignore_boundary
      end

      intersect = ((yi > point[1]) != (yj > point[1])) &&
                  (point[0] < (xj - xi) * (point[1] - yi).to_f / (yj - yi) + xi)
      if intersect
        is_inside = !is_inside
      end
    end
    is_inside
  end
end
