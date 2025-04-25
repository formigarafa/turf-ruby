# frozen_string_literal: true

# :nodoc:
module Turf
  # Returns true if a point is on a line. Accepts an optional parameter to ignore the
  # start and end vertices of the linestring.
  #
  # @param [Hash] pt GeoJSON Point
  # @param [Hash] line GeoJSON LineString
  # @param [Hash] options Optional parameters
  # @option options [Boolean] :ignore_end_vertices whether to ignore the start and end vertices.
  # @option options [Float] :epsilon Fractional number to compare with the cross product result.
  # Useful for dealing with floating points such as lng/lat points
  # @return [Boolean] true/false
  # @example
  #   pt = turf_point([0, 0])
  #   line = turf_line_string([[-1, -1], [1, 1], [1.5, 2.2]])
  #   is_point_on_line = boolean_point_on_line(pt, line)
  #   # => true
  def boolean_point_on_line(point, line, options = nil)
    options ||= {}
    # Normalize inputs
    pt_coords = get_coord(point)
    line_coords = get_coords(line)

    # Main
    line_coords.each_cons(2) do |line_segment_start, line_segment_end|
      ignore_boundary = false
      if options[:ignore_end_vertices]
        first_segment = (line_coords.first == line_segment_start)
        last_segment = (line_coords.last == line_segment_end)

        if first_segment && last_segment
          ignore_boundary = :both
        elsif first_segment
          ignore_boundary = :start
        elsif last_segment
          ignore_boundary = :end
        end
      end

      return true if is_point_on_line_segment(
        line_segment_start,
        line_segment_end,
        pt_coords,
        ignore_boundary,
        options[:epsilon],
      )
    end

    false
  end

  # Determines if a point is on a line segment.
  #
  # @param [Array<Float>] line_segment_start Coordinate pair of the start of the line segment [x1, y1].
  # @param [Array<Float>] line_segment_end Coordinate pair of the end of the line segment [x2, y2].
  # @param [Array<Float>] pt Coordinate pair of the point to check [px, py].
  # @param [Boolean, String] exclude_boundary Whether the point is allowed to fall on the line ends.
  # Can be true, false, or one of "start", "end", or "both".
  # @param [Float, NilClass] epsilon Fractional tolerance for cross-product
  # comparison (useful for floating-point coordinates).
  # @return [Boolean] true if the point is on the line segment, false otherwise.
  def is_point_on_line_segment(line_segment_start, line_segment_end, point, exclude_boundary, epsilon = nil)
    x, y = point
    x1, y1 = line_segment_start
    x2, y2 = line_segment_end

    dxc = x - x1
    dyc = y - y1
    dxl = x2 - x1
    dyl = y2 - y1
    cross = (dxc * dyl) - (dyc * dxl)

    if epsilon
      return false if cross.abs > epsilon
    elsif cross != 0
      return false
    end

    # Special case: zero-length line segments
    if dxl == 0 && dyl == 0
      return false if exclude_boundary

      return point == line_segment_start
    end

    case exclude_boundary
    when false
      if dxl.abs >= dyl.abs
        if dxl > 0
          x.between?(x1,
                     x2)
        else
          x.between?(x2,
                     x1)
        end
      else
        (if dyl > 0
           y.between?(y1,
                      y2)
         else
           y.between?(y2, y1)
         end)
      end
    when :start
      if dxl.abs >= dyl.abs
        dxl > 0 ? x1 < x && x <= x2 : x2 <= x && x < x1
      else
        (dyl > 0 ? y1 < y && y <= y2 : y2 < y && y < y1)
      end
    when :end
      if dxl.abs >= dyl.abs
        dxl > 0 ? x1 <= x && x < x2 : x2 < x && x <= x1
      else
        (dyl > 0 ? y1 <= y && y < y2 : y2 < y && y <= y1)
      end
    when :both
      if dxl.abs >= dyl.abs
        dxl > 0 ? x1 < x && x < x2 : x2 < x && x < x1
      else
        (dyl > 0 ? y1 < y && y < y2 : y2 < y && y < y1)
      end
    else
      false
    end
  end
end
