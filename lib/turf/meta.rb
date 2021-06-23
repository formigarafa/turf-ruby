# frozen_string_literal: true

#:nodoc:
module Turf
  # @!group Meta

  # Iterate over coordinates in any GeoJSON object, similar to Array.forEach()
  # @see https://turfjs.org/docs/#coordEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param exclude_wrap_coord [boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration
  # @yield [current_coord, coord_index] given any coordinate
  # @yieldparam current_coord [Array<number>] The current coordinate being processed.
  # @yieldparam coord_index [number] The current index of the coordinate being processed.
  def coord_each(geojson, exclude_wrap_coord: false, &block)
    return unless geojson

    geojson = deep_symbolize_keys geojson
    geometries = []
    case geojson[:type]
    when "FeatureCollection"
      geojson[:features].each do |feature|
        geometries.push feature[:geometry]
      end
    when "Feature"
      geometries.push geojson[:geometry]
    else
      geometries.push geojson
    end

    # flatten GeometryCollection
    geometries =
      geometries.map do |geometry|
        next if geometry.nil?
        next geometry unless geometry[:type] == "GeometryCollection"

        geometry[:geometries]
      end.flatten

    coords =
      geometries.flat_map do |geometry|
        next nil if geometry.nil?

        case geometry[:type]
        when "Point"
          [geometry[:coordinates]]
        when "LineString", "MultiPoint"
          geometry[:coordinates]
        when "Polygon", "MultiLineString"
          geometry[:coordinates].flat_map do |line_coords|
            (
              exclude_wrap_coord ? line_coords.slice(0...-1) : line_coords
            )
          end
        when "MultiPolygon"
          geometry[:coordinates].flat_map do |polygon_coords|
            polygon_coords.flat_map do |line_coords|
              (
                exclude_wrap_coord ? line_coords.slice(0...-1) : line_coords
              )
            end
          end
        when "Feature"
          [].tap do |feature_coords|
            coord_each geometry, exclude_wrap_coord: exclude_wrap_coord do |coord|
              feature_coords.push coord
            end
          end
        else
          raise Error, "Unknown Geometry Type: #{geometry[:type]}"
        end
      end.compact

    coords.each_with_index(&block)
  end

  # Iterate over features in any GeoJSON object, similar to Array.forEach.
  # @see https://turfjs.org/docs/#featureEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @yield [feature] given any coordinate
  # @yieldparam feature [Feature<any>] currentFeature The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  def feature_each(geojson, &block)
    return unless geojson

    geojson = deep_symbolize_keys geojson
    case geojson[:type]
    when "Feature"
      yield geojson, 0
    when "FeatureCollection"
      geojson[:features].each_with_index(&block)
    end
  end
end
