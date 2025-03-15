# frozen_string_literal: true

require_relative "helpers"

# :nodoc:
module Turf
  # @!group Meta

  # Iterate over coordinates in any GeoJSON object, similar to Array.forEach(*args)
  # @see https://turfjs.org/docs/#coordEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param exclude_wrap_coord [boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration
  # @yield [current_coord, coord_index] given any coordinate
  # @yieldparam current_coord [Array<number>] The current coordinate being processed.
  # @yieldparam coord_index [number] The current index of the coordinate being processed.
  def coord_each(geojson, exclude_wrap_coord: false, &block)
    coord_all(geojson, exclude_wrap_coord: exclude_wrap_coord, &block)
  end

  # Get all coordinates from any GeoJSON object.
  # @see https://turfjs.org/docs/#coordAll
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param exclude_wrap_coord [boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration
  # @return [Array<Array<number>>] coordinate position array
  def coord_all(geojson, exclude_wrap_coord: false, &block)
    geometry_index = -1
    geom_each(geojson) do |geometry, _idx, _properties|
      if geometry.nil?
        next
      end

      case geometry[:type]
      when "Point"
        geometry_index += 1
        block.call(geometry[:coordinates], geometry_index)
      when "LineString", "MultiPoint"
        geometry[:coordinates].each do |coords|
          geometry_index += 1
          block.call(coords, geometry_index)
        end
      when "Polygon", "MultiLineString"
        geometry[:coordinates].each do |line_coords|
          if exclude_wrap_coord
            line_coords = line_coords[0...-1]
          end
          line_coords.each do |coords|
            geometry_index += 1
            block.call(coords, geometry_index)
          end
        end
      when "MultiPolygon"
        geometry[:coordinates].each do |polygon_coords|
          polygon_coords.each do |line_coords|
            if exclude_wrap_coord
              line_coords = line_coords[0...-1]
            end
            line_coords.each do |coords|
              geometry_index += 1
              block.call(coords, geometry_index)
            end
          end
        end
      when "Feature"
        coord_each(geometry, exclude_wrap_coord: exclude_wrap_coord, &block)
      else
        raise Error, "Unknown Geometry Type: #{geometry[:type]}"
      end
    end
    geojson
  end

  # Reduce coordinates in any GeoJSON object, similar to Array.reduce(*args)
  # @see https://turfjs.org/docs/#coordReduce
  # @param geojson [FeatureCollection|Geometry|Feature] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @param exclude_wrap_coord [Boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration.
  # @return [*] The value that results from the reduction.
  def coord_reduce(geojson, initial_value = nil, exclude_wrap_coord: false)
    previous_value = initial_value

    coord_each(
      geojson,
      exclude_wrap_coord: exclude_wrap_coord,
    ) do |current_coord, coord_index|
      previous_value =
        if coord_index.zero? && initial_value.nil?
          current_coord
        else
          yield(
            previous_value,
            current_coord,
            coord_index
          )
        end
    end

    previous_value
  end

  # Iterate over each geometry in any GeoJSON object, similar to Array.forEach(*args)
  # @see https://turfjs.org/docs/#geomReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @yieldparam geom [Geometry] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @yieldparam properties [Hash] an Object of key-value pairs to add as properties
  # @yieldparam bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @yieldparam id [string|number] Identifier associated with the Feature
  def geom_each(geojson)
    return unless geojson

    geojson = deep_symbolize_keys! geojson

    entries = []

    case geojson[:type]
    when "FeatureCollection"
      geojson[:features].each do |feature|
        entries.push [feature[:geometry], feature[:properties], feature[:bbox], feature[:id]]
      end
    when "Feature"
      entries.push [geojson[:geometry], geojson[:properties], geojson[:bbox], geojson[:id]]
    else
      entries.push [geojson, {}, nil, nil]
    end

    entry_index = -1

    # flatten GeometryCollection
    entries.each do |entry|
      geometry, properties, bbox, id = entry
      if geometry.nil? || geometry[:type] != "GeometryCollection"
        yield(geometry, (entry_index += 1), properties, bbox, id)
      else
        geometry[:geometries].each do |sub_geometry|
          yield(sub_geometry, (entry_index += 1), properties, bbox, id)
        end
      end
    end
  end

  # Reduce geometry in any GeoJSON object, similar to Array.reduce(*args).
  # @see https://turfjs.org/docs/#geomReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [*] Result of previous reduction
  # @yieldparam geom [Geometry] The current Feature being processed.
  # @yieldparam geom_index [number] The current index of the Feature being processed.
  # @yieldparam properties [Hash] an Object of key-value pairs to add as properties
  # @yieldparam bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @yieldparam id [string|number] Identifier associated with the Feature
  # @return [*] The value that results from the reduction.
  def geom_reduce(geojson, initial_value = nil)
    previous_value = initial_value

    geom_each(
      geojson,
    ) do |geom, geom_index, properties, bbox, id|
      previous_value =
        if geom_index.zero? && initial_value.nil?
          geom
        else
          yield(
            previous_value,
            geom,
            geom_index,
            properties,
            bbox,
            id
          )
        end
    end

    previous_value
  end

  # Get all Geometry
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @return [Array<Geometry>] list of Geometry
  def geometries(geojson)
    geometries = []
    geom_each(geojson) do |geometry|
      geometries.push(geometry)
    end
    geometries
  end

  # Iterate over features in any GeoJSON object, similar to Array.forEach.
  # @see https://turfjs.org/docs/#featureEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @yield [feature] given any coordinate
  # @yieldparam feature [Feature<any>] currentFeature The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  def feature_each(geojson, &block)
    return unless geojson

    features = []
    geojson = deep_symbolize_keys! geojson
    case geojson[:type]
    when "Feature"
      features.push geojson
    when "FeatureCollection"
      features.push(*geojson[:features])
    end

    features.each_with_index(&block)
  end

  # Reduce features in any GeoJSON object, similar to Array.reduce(*args).
  # @see https://turfjs.org/docs/#featureReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [*] Result of previous reduction
  # @yieldparam feature [Feature<any>] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @return [*] The value that results from the reduction.
  def feature_reduce(geojson, initial_value = nil)
    previous_value = initial_value

    feature_each(
      geojson,
    ) do |feature, feature_index|
      previous_value =
        if feature_index.zero? && initial_value.nil?
          feature
        else
          yield(
            previous_value,
            feature,
            feature_index
          )
        end
    end

    previous_value
  end

  # Iterate over flattened features in any GeoJSON object, similar to Array.forEach.
  # @see https://turfjs.org/docs/#flattenEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @yieldparam feature [Feature<any>] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @yieldparam multi_feature_index [number] The current index of the Feature in the multi-Feature
  def flatten_each(geojson)
    geom_each(geojson) do |geometry, feature_index, properties, bbox, id|
      if geometry.nil?
        next yield(
          feature(nil, properties, bbox: bbox, id: id),
          feature_index,
          0
        )
      end

      case geometry[:type]
      when "Point", "LineString", "Polygon"
        yield(
          feature(geometry, properties, bbox: bbox, id: id),
          feature_index,
          0
        )
      when "MultiPoint", "MultiLineString", "MultiPolygon"
        geom_type = geometry[:type].sub(/^Multi/, "")
        geometry[:coordinates].each_with_index do |coordinate, multi_feature_index|
          geom = {
            type: geom_type,
            coordinates: coordinate
          }
          yield(
            feature(geom, properties),
            feature_index,
            multi_feature_index
          )
        end
      end
    end
  end

  # Reduce flattened features in any GeoJSON object, similar to Array.reduce(*args).
  # @see https://turfjs.org/docs/#flattenEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [*] Result of previous reduction
  # @yieldparam feature [Feature<any>] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @yieldparam multi_feature_index [number] The current index of the Feature in the multi-Feature
  # @return [*] The value that results from the reduction.
  def flatten_reduce(geojson, initial_value = nil)
    previous_value = initial_value

    flatten_each(
      geojson,
    ) do |feature, feature_index, multi_feature_index|
      previous_value =
        if feature_index.zero? && multi_feature_index.zero? && initial_value.nil?
          feature
        else
          yield(
            previous_value,
            feature,
            feature_index,
            multi_feature_index
          )
        end
    end

    previous_value
  end

  # Iterate over 2-vertex line segment in any GeoJSON object, similar to Array.forEach(*args)
  # (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
  # @see https://turfjs.org/docs/#segmentEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  def segment_each(geojson)
    flatten_each(geojson) do |feature, feature_index|
      # Exclude null Geometries
      return if feature[:geometry].nil?

      # (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
      type = feature[:geometry][:type]
      return if %w[Point MultiPoint].include?(type)

      segment_index = 0

      # Generate 2-vertex line segments
      previous_coords = nil
      previous_feature_index = 0
      coord_each(feature) do |current_coord|
        # Simulating a meta.coord_reduce(*args) since `reduce` operations cannot be stopped by returning `false`
        if previous_coords.nil? || feature_index > previous_feature_index
          previous_coords = current_coord
          previous_feature_index = feature_index
          segment_index = 0
          next
        end

        segment = Turf.line_string([previous_coords, current_coord], feature[:properties])
        next unless yield(segment, feature_index)

        segment_index += 1
        previous_coords = current_coord
      end
    end
  end

  def segment_reduce(geojson, initial_value = nil)
    previous_value = initial_value
    started = false

    segment_each(geojson) do |segment, feature_index, multifeature_index, geometry_index, segment_index|
      previous_value =
        if !started && initial_value.nil?
          segment
        else
          yield(
            previous_value,
            segment,
            feature_index,
            multifeature_index,
            geometry_index,
            segment_index
          )
        end
      started = true
    end

    previous_value
  end

  def prop_each(*args)
  end

  def prop_reduce(*args)
  end

  def line_reduce(*args)
  end

  def line_each(*args)
  end

  def find_segment(*args)
  end

  def find_point(*args)
  end
end
