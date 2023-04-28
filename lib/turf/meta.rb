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
    coord_all(geojson, exclude_wrap_coord: exclude_wrap_coord).each_with_index(&block)
  end

  # Get all coordinates from any GeoJSON object.
  # @see https://turfjs.org/docs/#coordAll
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param exclude_wrap_coord [boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration
  # @return [Array<Array<number>>] coordinate position array
  def coord_all(geojson, exclude_wrap_coord: false)
    geometries = self.geometries(geojson)
    geometries.flat_map do |geometry|
      next [] if geometry.nil?

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
    end
  end

  # Reduce coordinates in any GeoJSON object, similar to Array.reduce()
  # @see https://turfjs.org/docs/#coordReduce
  # @param geojson [FeatureCollection|Geometry|Feature] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @param exclude_wrap_coord [Boolean] whether or not to include the final coordinate of LinearRings that wraps the
  # ring in its iteration.
  # @return [*] The value that results from the reduction.
  def coord_reduce(geojson, initial_value: nil, exclude_wrap_coord: false)
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

  # Iterate over each geometry in any GeoJSON object, similar to Array.forEach()
  # @see https://turfjs.org/docs/#geomReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @yieldparam geom [Geometry] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @yieldparam properties [Hash] an Object of key-value pairs to add as properties
  # @yieldparam bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @yieldparam id [string|number] Identifier associated with the Feature
  def geom_each(geojson)
    return unless geojson

    geojson = deep_symbolize_keys geojson

    # [geometry, properties, bbox, id]
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

    # flatten GeometryCollection
    entries =
      entries.flat_map do |entry|
        geometry, properties, bbox, id = entry
        next [entry] if geometry.nil?
        next [entry] unless geometry[:type] == "GeometryCollection"

        geometry[:geometries].map do |sub_geometry|
          [sub_geometry, properties, bbox, id]
        end
      end

    entries.each_with_index do |entry, entry_index|
      geometry, properties, bbox, id = entry
      yield geometry, entry_index, properties, bbox, id
    end
  end

  # Reduce geometry in any GeoJSON object, similar to Array.reduce().
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
  def geom_reduce(geojson, initial_value: nil)
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
    [].tap do |geometries|
      geom_each(geojson) do |geometry|
        geometries.push(geometry)
      end
    end
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
    geojson = deep_symbolize_keys geojson
    case geojson[:type]
    when "Feature"
      features.push geojson
    when "FeatureCollection"
      features.push(*geojson[:features])
    end

    features.each_with_index(&block)
  end

  # Reduce features in any GeoJSON object, similar to Array.reduce().
  # @see https://turfjs.org/docs/#featureReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [*] Result of previous reduction
  # @yieldparam feature [Feature<any>] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @return [*] The value that results from the reduction.
  def feature_reduce(geojson, initial_value: nil)
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
          feature(nil, properties: properties, bbox: bbox, id: id),
          feature_index,
          0
        )
      end

      case geometry[:type]
      when "Point", "LineString", "Polygon"
        yield(
          feature(geometry, properties: properties, bbox: bbox, id: id),
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
            feature(geom, properties: properties),
            feature_index,
            multi_feature_index
          )
        end
      end
    end
  end

  # Reduce flattened features in any GeoJSON object, similar to Array.reduce().
  # @see https://turfjs.org/docs/#flattenEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [*] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [*] Result of previous reduction
  # @yieldparam feature [Feature<any>] The current Feature being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @yieldparam multi_feature_index [number] The current index of the Feature in the multi-Feature
  # @return [*] The value that results from the reduction.
  def flatten_reduce(geojson, initial_value: nil)
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

  # Iterate over 2-vertex line segment in any GeoJSON object, similar to Array.forEach()
  # (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
  # @see https://turfjs.org/docs/#segmentEach
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  def segment_each(geojson)
    flatten_each(geojson) do |feature, feature_index, multi_feature_index|
      # Exclude null Geometries
      return if feature[:geometry].nil?

      # (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
      type = feature[:geometry][:type]
      return if type == "Point" || type == "MultiPoint"

      segment_index = 0

      # Generate 2-vertex line segments
      previous_coords = nil
      previous_feature_index = 0
      prev_geom_index = 0
      coord_each(feature) do |current_coord, coord_index|
        # Simulating a meta.coord_reduce() since `reduce` operations cannot be stopped by returning `false`
        if previous_coords.nil? || feature_index > previous_feature_index
          previous_coords = current_coord
          previous_feature_index = feature_index
          segment_index = 0
          next
        end

        segment = Turf.line_string([previous_coords, current_coord], properties: feature[:properties])
        next unless yield(segment, feature_index)
        segment_index += 1
        previous_coords = current_coord
      end
    end
  end

  def segment_reduce(geojson, initial_value: nil)
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
end
