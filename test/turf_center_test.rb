# frozen_string_literal: true

require "test_helper"

class TurfCenterTest < Minitest::Test
  def setup
    @directories = {
      in: File.join(__dir__, "center", "in"),
      out: File.join(__dir__, "center", "out")
    }
    @fixtures = Dir.glob(File.join(@directories[:in], "*.geojson")).map do |input|
      {
        name: File.basename(input, File.extname(input)),
        filename: File.basename(input),
        geojson: JSON.parse(File.read(input), symbolize_names: true),
        out: File.join(@directories[:out], File.basename(input))
      }
    end
  end

  def test_turf_center
  end

  def test_turf_center_properties
  end
end
