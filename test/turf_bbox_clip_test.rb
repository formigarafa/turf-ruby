# frozen_string_literal: true

require "test_helper"

class TurfBBoxClipTest < Minitest::Test
  def setup
    @directories = {
      in: File.join(__dir__, "bbox_clip", "in"),
      out: File.join(__dir__, "bbox_clip", "out")
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

  def test_turf_bbox_clip
  end

  def test_bbox_clip_throws
  end

  def test_bbox_clip_null_geometries
  end
end
