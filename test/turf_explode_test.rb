# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-explode/test.js
class TurfExplodeTest < Minitest::Test
  def fixtures
    Dir.glob(File.expand_path("explode/in/*.json", __dir__)).map do |fixture_full_path|
      {
        filename: File.basename(fixture_full_path),
        name: File.basename(fixture_full_path, ".json"),
        geojson: load_geojson(fixture_full_path, symbolize_names: true)
      }
    end
  end

  def test_explode_fixtures
    fixtures.each do |fixture|
      exploded = Turf.explode(fixture[:geojson])

      assert_equal exploded, load_geojson("explode/out/#{fixture[:name]}.json", symbolize_names: true), fixture[:name]
    end
  end

  def test_explode_preserve_properties
    filename = "polygon-with-properties"
    features = load_geojson("explode/in/#{filename}.json", symbolize_names: true)
    exploded = Turf.explode(features)

    assert_equal(exploded, load_geojson("explode/out/#{filename}.json", symbolize_names: true), "properties")
  end
end
