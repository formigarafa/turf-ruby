# frozen_string_literal: true

require "test_helper"

class TurfInvariantTest < Minitest::Test
  def test_get_coord
    assert_equal [1, 2], Turf.get_coord([1, 2])
    assert_equal [1, 2], Turf.get_coord(
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [1, 2],
      },
    )
    assert_equal [1, 2], Turf.get_coord(
      type: "Point",
      coordinates: [1, 2],
    )
  end
end
