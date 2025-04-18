# frozen_string_literal: true

# :nodoc:
module Turf
  def to_mercator(*args)
    raise NotImplementedError
  end

  def to_wgs84(*args)
    raise NotImplementedError
  end
end
