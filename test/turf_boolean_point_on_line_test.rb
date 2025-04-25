# frozen_string_literal: true

require "test_helper"

class TurfBooleanPointOnLineTest < Minitest::Test
  def test_turf_boolean_point_on_line_true_fixtures
    # True Fixtures
    Dir.glob(File.join(__dir__, "boolean_point_on_line", "true", "**", "*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath), symbolize_names: true)
      options = geojson[:properties]
      feature1 = geojson[:features][0]
      feature2 = geojson[:features][1]
      result = Turf.boolean_point_on_line(feature1, feature2, options)

      assert result, "[true] #{name}"
    end
  end

  def test_turf_boolean_point_on_line_false_fixtures
    # False Fixtures
    Dir.glob(File.join(__dir__, "boolean_point_on_line", "false", "**", "*.geojson")).each do |filepath|
      name = File.basename(filepath, ".geojson")
      geojson = JSON.parse(File.read(filepath), symbolize_names: true)
      options = geojson[:properties]
      feature1 = geojson[:features][0]
      feature2 = geojson[:features][1]
      result = Turf.boolean_point_on_line(feature1, feature2, options)

      refute result, "[false] #{name}"
    end
  end

  def test_turf_boolean_point_on_line_issue_2750
    # Issue 2750 Tests
    point1 = Turf.point([2, 13])
    zero_length_line = Turf.line_string([[1, 1], [1, 1]])
    refute Turf.boolean_point_on_line(point1, zero_length_line),
           "#2750 different longitude point not on zero length line"

    point2 = Turf.point([1, 13])
    refute Turf.boolean_point_on_line(point2, zero_length_line),
           "#2750 same longitude point not on zero length line"
  end
end
