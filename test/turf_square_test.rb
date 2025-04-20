# frozen_string_literal: true

require "test_helper"

class TurfSquareTest < Minitest::Test
  def test_square
    # Bounding boxes to be tested
    bbox1 = [0, 0, 5, 10]
    bbox2 = [0, 0, 10, 5]

    # Call the square function from the Turf module
    sq1 = Turf.square(bbox1)
    sq2 = Turf.square(bbox2)

    # Assertions to check if the results match the expected values
    assert_equal([-2.5, 0, 7.5, 10], sq1, "Square function should properly calculate the square for bbox1")
    assert_equal([0, -2.5, 10, 7.5], sq2, "Square function should properly calculate the square for bbox2")
  end
end
