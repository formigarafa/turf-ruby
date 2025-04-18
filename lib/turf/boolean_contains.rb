# frozen_string_literal: true

# :nodoc:
module Turf
  def boolean_contains(*args)
    raise NotImplementedError
  end

  def is_polygon_in_multi_polygon(*args)
    raise NotImplementedError
  end

  def is_point_in_multi_point(*args)
    raise NotImplementedError
  end

  def is_multi_point_in_multi_point(*args)
    raise NotImplementedError
  end

  def is_multi_point_on_line(*args)
    raise NotImplementedError
  end

  def is_multi_point_in_poly(*args)
    raise NotImplementedError
  end

  def is_line_on_line(*args)
    raise NotImplementedError
  end

  def is_line_in_poly(*args)
    raise NotImplementedError
  end

  def is_poly_in_poly(*args)
    raise NotImplementedError
  end

  def do_b_box_overlap(*args)
    raise NotImplementedError
  end

  def compare_coords(*args)
    raise NotImplementedError
  end

  def get_midpoint(*args)
    raise NotImplementedError
  end
end
