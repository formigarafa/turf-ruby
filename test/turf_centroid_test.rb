# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-centroid/test.js
class TurfCentroidTest < Minitest::Test
  def setup
    @directories = {
      in: File.join(__dir__, 'centroid', 'in'),
      out: File.join(__dir__, 'centroid', 'out')
    }
    @fixtures = Dir.glob(File.join(@directories[:in], '*.geojson')).map do |input|
      {
        name: File.basename(input, File.extname(input)),
        filename: File.basename(input),
        geojson: JSON.parse(File.read(input), symbolize_names: true),
        out: File.join(@directories[:out], File.basename(input))
      }
    end
  end

  def test_centroid
    @fixtures.each do |fixture|
      name = fixture[:name]
      geojson = fixture[:geojson]
      out = fixture[:out]
      centered = Turf.centroid(geojson, { 'marker-symbol': 'circle' })
      result = Turf.feature_collection([centered])
      Turf.feature_each(geojson) { |feature| result[:features] << feature }

      assert_equal JSON.parse(File.read(out), symbolize_names: true), result, name
    end
  end

  def test_centroid_properties
    line = Turf.line_string(
      [
        [0, 0],
        [1, 1]
      ]
    )
    pt = Turf.centroid(line, { foo: 'bar' })
    assert_equal 'bar', pt.dig(:properties, :foo), 'translate properties'
  end
end
