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
    @fixtures.each do |fixture|
      geojson = fixture[:geojson]
      options = geojson[:options] || {}
      options[:properties] = { "marker-symbol": "star", "marker-color": "#F00" }
      centered = Turf.center(geojson, options)

      # Display Results
      results = Turf.feature_collection([centered])
      Turf.feature_each(geojson) { |feature| results[:features] << feature }

      extent = Turf.bbox_polygon(Turf.bbox(geojson))
      extent[:properties] = { stroke: "#00F", "stroke-width": 1, "fill-opacity": 0 }
      Turf.coord_each(extent) do |coord|
        results[:features] << Turf.line_string(
          [coord, centered[:geometry][:coordinates]],
          {
            stroke: "#00F",
            "stroke-width": 1
          },
        )
      end
      results[:features] << extent

      out_path = File.join(@directories[:out], fixture[:filename])
      expected = JSON.parse(File.read(out_path), symbolize_names: true)
      assert_equal(expected, results, "Testing #{fixture[:name]}")
    end
  end

  def test_turf_center_properties
    line = Turf.line_string([
      [0, 0],
      [1, 1],
    ])
    pt = Turf.center(line, properties: { foo: "bar" })

    assert_equal("bar", pt[:properties][:foo], "translate properties")
  end
end
