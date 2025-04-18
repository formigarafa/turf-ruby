# frozen_string_literal: true

# :nodoc:
module Turf
  def polygon_to_line(*args)
    raise NotImplementedError
  end

  def coords_to_line(*args)
    raise NotImplementedError
  end

  def multi_polygon_to_line(*args)
    raise NotImplementedError
  end

  def single_polygon_to_line(*args)
    raise NotImplementedError
  end
end
