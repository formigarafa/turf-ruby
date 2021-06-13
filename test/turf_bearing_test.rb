# frozen_string_literal: true

require "test_helper"

class TurfBearingTest < Minitest::Test
  def test_bearing
    from = Turf.point([-75, 45], "marker-color": "#F00")
    to = Turf.point([20, 60], "marker-color": "#00F")

    initial_bearing = Turf.bearing(from, to)
    assert_equal format("%<bearing>.2f", bearing: initial_bearing), "37.75"

    final_bearing = Turf.bearing(from, to, final: true)
    assert_equal format("%<bearing>.2f", bearing: final_bearing), "120.01"
  end
end
