# frozen_string_literal: true

# :nodoc:
module Turf
  def random_position(*args)
    raise NotImplementedError
  end

  def random_point(*args)
    raise NotImplementedError
  end

  def random_polygon(*args)
    raise NotImplementedError
  end

  def random_line_string(*args)
    raise NotImplementedError
  end
end
