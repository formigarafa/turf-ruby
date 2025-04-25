# frozen_string_literal: true

# Takes a ring and returns true or false whether or not the ring is clockwise or counter-clockwise.
#
# @param [Array<Array<Number>>] line to be evaluated
# @return [Boolean] true/false
# @example
#   clockwise_ring = [[0, 0], [1, 1], [1, 0], [0, 0]]
#   counter_clockwise_ring = [[0, 0], [1, 0], [1, 1], [0, 0]]
#
#   boolean_clockwise(clockwise_ring)
#   # => true
#   boolean_clockwise(counter_clockwise_ring)
#   # => false
module Turf
  def boolean_clockwise(line)
    ring = get_coords(line)
    sum = 0

    ring.each_cons(2) do |prev, cur|
      sum += (cur[0] - prev[0]) * (cur[1] + prev[1])
    end

    sum > 0
  end
end
