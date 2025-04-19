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
    @fixtures.each do |fixture|
      geojson = fixture[:geojson]
      feature = geojson[:features][0]
      bbox = Turf.bbox(geojson[:features][1])
      clipped = Turf.bbox_clip(feature, bbox)

      results = Turf.feature_collection([
        colorize(feature, "#080"),
        colorize(clipped, "#F00"),
        colorize(geojson[:features][1], "#00F", 3),
      ])

      expected = JSON.parse(File.read(fixture[:out]), symbolize_names: true)
      assert_equal(expected, results, fixture[:name])
    end
  end

  def test_bbox_clip_throws
    assert_raises(RuntimeError, "geometry Point not supported") do
      Turf.bbox_clip(Turf.point([5, 10]), [-180, -90, 180, 90])
    end
  end

  def test_bbox_clip_null_geometries
    assert_raises(RuntimeError, "coords must be GeoJSON Feature, Geometry Object or an Array") do
      Turf.bbox_clip(Turf.feature(nil), [-180, -90, 180, 90])
    end
  end

  private

  def colorize(feature, color, width = 6)
    color ||= "#F00"
    feature[:properties] ||= {}
    feature[:properties].merge!(
      stroke: color,
      fill: color,
      "stroke-width": width,
      "fill-opacity": 0.1,
    )
    feature
  end
end
