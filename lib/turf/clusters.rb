# frozen_string_literal: true

# :nodoc:
module Turf
  def get_cluster(*args)
    raise NotImplementedError
  end

  def cluster_each(*args)
    raise NotImplementedError
  end

  def cluster_reduce(*args)
    raise NotImplementedError
  end

  def create_bins(*args)
    raise NotImplementedError
  end

  def apply_filter(*args)
    raise NotImplementedError
  end

  def properties_contains_filter(*args)
    raise NotImplementedError
  end

  def filter_properties(*args)
    raise NotImplementedError
  end
end
