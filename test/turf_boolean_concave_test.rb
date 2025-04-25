# frozen_string_literal: true

require "test_helper"

class TurfBooleanConcaveTest < Minitest::Test
  def test_is_concave_fixtures
    # True Fixtures
    Dir.glob(File.join(__dir__, "boolean_concave", "true", "*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath), symbolize_names: true)
      feature = geojson[:features][0]
      assert(Turf.boolean_concave(feature), "[true] #{name}")
    end

    # False Fixtures
    Dir.glob(File.join(__dir__, "boolean_concave", "false", "*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath), symbolize_names: true)
      feature = geojson[:features][0]
      refute(Turf.boolean_concave(feature), "[false] #{name}")
    end
  end

  def test_is_concave_geometry_types
    poly = Turf.polygon([
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 0],
        [0, 0],
      ],
    ])

    assert_equal(false, Turf.boolean_concave(poly), "Feature")
    assert_equal(false, Turf.boolean_concave(poly[:geometry]), "Geometry Object")
  end
end
