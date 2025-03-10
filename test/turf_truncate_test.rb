# frozen_string_literal: true

require "test_helper"
# @see https://github.com/Turfjs/turf/blob/master/packages/turf-truncate/test.js
class TurfTruncateTest < Minitest::Test
  def fixtures
    Dir.glob(File.expand_path("truncate/in/*.geojson", __dir__)).map do |fixture_full_path|
      {
        filename: File.basename(fixture_full_path),
        name: File.basename(fixture_full_path, ".geojson"),
        geojson: load_geojson(fixture_full_path, symbolize_names: true)
      }
    end
  end

  def test_turf_truncate
    fixtures.each do |fixture|
      name = fixture[:name]
      geojson = fixture[:geojson]

      options = (geojson[:properties] || {}).slice(:precision, :coordinates).compact

      results = Turf.truncate(geojson, options)
      expectations = load_geojson("truncate/out/#{name}.geojson", symbolize_names: true)
      assert_equal(results, expectations)
    end
  end

  def test_turf_truncate_precision_and_coordinates
    assert_equal(Turf.truncate(Turf.point([50.1234567, 40.1234567]), { precision: 3 }).dig(:geometry, :coordinates),
                 [50.123, 40.123], "precision 3")
    assert_equal(Turf.truncate(Turf.point([50.1234567, 40.1234567]), { precision: 0 }).dig(:geometry, :coordinates),
                 [50, 40], "precision 0")
    assert_equal(Turf.truncate(Turf.point([50, 40, 1100]), { precision: 6 }).dig(:geometry, :coordinates),
                 [50, 40, 1100], "coordinates default to 3")
    assert_equal(
      Turf.truncate(Turf.point([50, 40, 1100]), { precision: 6, coordinates: 2 }).dig(:geometry, :coordinates),
      [50, 40],
      "coordinates 2",
    )
  end

  def test_turf_truncate_prevent_input_mutation
    pt = Turf.point([120.123, 40.123, 3000])
    pt_before = JSON.parse(JSON.generate(pt), symbolize_names: true)

    Turf.truncate(pt, { precision: 0 })
    assert_equal(pt_before, pt, "does not mutate input")

    Turf.truncate(pt, { precision: 0, coordinates: 2, mutate: true })
    assert_equal(pt, Turf.point([120, 40]), "does mutate input")
  end
end
