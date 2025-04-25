# frozen_string_literal: true

# :nodoc:
module Turf
  # frozen_string_literal: true

  # Takes a polygon and returns true or false as to whether it is concave or not.
  #
  # @function
  # @param [Feature<Polygon>, Polygon] polygon to be evaluated
  # @return [Boolean] true/false
  # @example
  #   convex_polygon = polygon([[[0, 0], [0, 1], [1, 1], [1, 0], [0, 0]]])
  #
  #   boolean_concave(convex_polygon)
  #   # => false
  def boolean_concave(polygon)
    coords = get_geom(polygon)[:coordinates]
    return false if coords[0].length <= 4

    sign = nil
    n = coords[0].length - 1

    (0...n).each do |i|
      dx1 = coords[0][(i + 2) % n][0] - coords[0][(i + 1) % n][0]
      dy1 = coords[0][(i + 2) % n][1] - coords[0][(i + 1) % n][1]
      dx2 = coords[0][i][0] - coords[0][(i + 1) % n][0]
      dy2 = coords[0][i][1] - coords[0][(i + 1) % n][1]
      zcrossproduct = (dx1 * dy2) - (dy1 * dx2)

      if i.zero?
        sign = zcrossproduct.positive?
      elsif sign != zcrossproduct.positive?
        return true
      end
    end

    false
  end
end
