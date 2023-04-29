# frozen_string_literal: true

require "test_helper"

class TurfLengthTest < Minitest::Test
  def test_length
    line = load_geojson("along/dc_line.geojson")
    options = { units: "miles" }
    length = Turf.length(line, **options).round(3)

    assert_equal 5.503, length
  end
end
