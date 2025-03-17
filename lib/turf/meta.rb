# frozen_string_literal: true

require_relative "helpers"

# :nodoc:
module Turf
  # Iterate over coordinates in any GeoJSON object, similar to Array#each.
  #
  # @param geojson [AllGeoJSON] any GeoJSON object
  # @yield [current_coord, coord_index, feature_index, multi_feature_index, geometry_index]
  # @yieldparam current_coord [Array<Number>] The current coordinate being processed.
  # @yieldparam coord_index [Integer] The current index of the coordinate being processed.
  # @yieldparam feature_index [Integer] The current index of the Feature being processed.
  # @yieldparam multi_feature_index [Integer] The current index of the Multi-Feature being processed.
  # @yieldparam geometry_index [Integer] The current index of the Geometry being processed.
  # @param exclude_wrap_coord [Boolean] whether or not to include the final coordinate
  # of LinearRings that wraps the ring in its iteration.
  # @return [void]
  # @example
  #   features = Turf.feature_collection([
  #     Turf.point([26, 37], {foo: "bar"}),
  #     Turf.point([36, 53], {hello: "world"})
  #   ])
  #
  #   Turf.coord_each(features, exclude_wrap_coord: false) do |
  #     current_coord,
  #     coord_index,
  #     feature_index,
  #     multi_feature_index,
  #     geometry_index
  #   |
  #     #=current_coord
  #     #=coord_index
  #     #=feature_index
  #     #=multi_feature_index
  #     #=geometry_index
  #   end
  def coord_each(geojson, exclude_wrap_coord: false)
    return if geojson.nil?

    coord_index = 0
    is_geometry_collection = false
    type = geojson[:type]
    is_feature_collection = type == "FeatureCollection"
    is_feature = type == "Feature"
    stop = is_feature_collection ? geojson[:features].length : 1

    (0...stop).each do |feature_index|
      geometry_maybe_collection = if is_feature_collection
                                    geojson[:features][feature_index][:geometry]
                                  elsif is_feature
                                    geojson[:geometry]
                                  else
                                    geojson
                                  end

      is_geometry_collection = if geometry_maybe_collection
                                 geometry_maybe_collection[:type] == "GeometryCollection"
                               else
                                 false
                               end
      stop_g = is_geometry_collection ? geometry_maybe_collection[:geometries].length : 1

      (0...stop_g).each do |geom_index|
        multi_feature_index = 0
        geometry_index = 0
        geometry = if is_geometry_collection
                     geometry_maybe_collection[:geometries][geom_index]
                   else
                     geometry_maybe_collection
                   end

        next if geometry.nil?

        coords = geometry[:coordinates]
        geom_type = geometry[:type]
        wrap_shrink = exclude_wrap_coord && %w[Polygon MultiPolygon].include?(geom_type) ? 1 : 0

        case geom_type
        when "Point"
          return false if yield(coords, coord_index, feature_index, multi_feature_index, geometry_index) == false

          coord_index += 1
          multi_feature_index += 1
        when "LineString", "MultiPoint"
          coords.each_with_index do |coord, _j|
            return false if yield(coord, coord_index, feature_index, multi_feature_index, geometry_index) == false

            coord_index += 1
            multi_feature_index += 1 if geom_type == "MultiPoint"
          end
          multi_feature_index += 1 if geom_type == "LineString"
        when "Polygon", "MultiLineString"
          coords.each_with_index do |coord, _j|
            (0...(coord.length - wrap_shrink)).each do |k|
              return false if yield(coord[k], coord_index, feature_index, multi_feature_index, geometry_index) == false

              coord_index += 1
            end
            multi_feature_index += 1 if geom_type == "MultiLineString"
            geometry_index += 1 if geom_type == "Polygon"
          end
          multi_feature_index += 1 if geom_type == "Polygon"
        when "MultiPolygon"
          coords.each_with_index do |coord, _j|
            geometry_index = 0
            coord.each_with_index do |inner_coord, _k|
              (0...(inner_coord.length - wrap_shrink)).each do |l|
                if yield(inner_coord[l], coord_index, feature_index, multi_feature_index, geometry_index) == false
                  return false
                end

                coord_index += 1
              end
              geometry_index += 1
            end
            multi_feature_index += 1
          end
        when "GeometryCollection"
          geometry[:geometries].each do |inner_geometry|
            return false if coord_each(inner_geometry, exclude_wrap_coord: exclude_wrap_coord, &Proc.new) == false
          end
        else
          raise Error, "Unknown Geometry Type"
        end
      end
    end
  end

  # Get all coordinates from any GeoJSON object.
  #
  # @param geojson [AllGeoJSON] any GeoJSON object
  # @return [Array<Array<Number>>] coordinate position array
  # @example
  #   features = Turf.feature_collection([
  #     Turf.point([26, 37], {foo: 'bar'}),
  #     Turf.point([36, 53], {hello: 'world'})
  #   ])
  #
  #   coords = Turf.coord_all(features)
  #   #= [[26, 37], [36, 53]]
  def coord_all(geojson)
    coords = []
    coord_each(geojson) do |coord|
      coords.push(coord)
    end
    coords
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
    flatten_each(geojson) do |feature, feature_index, multi_feature_index|
      # Exclude null Geometries
      return if feature[:geometry].nil?

      # (Multi)Point geometries do not contain segments therefore they are ignored during this operation.
      type = feature[:geometry][:type]
      return if %w[Point MultiPoint].include?(type)

      segment_index = 0

      # Generate 2-vertex line segments
      previous_coords = nil
      previous_feature_index = 0
      previous_multi_index = 0
      prev_geom_index = 0
      coord_each(feature) do |current_coord, _coord_index, _feature_index_coord, multi_part_index_coord, geometry_index|
        # Simulating a meta.coord_reduce(*args) since `reduce` operations cannot be stopped by returning `false`
        if previous_coords.nil? ||
           feature_index > previous_feature_index ||
           multi_part_index_coord > previous_multi_index ||
           geometry_index > prev_geom_index

          previous_coords = current_coord
          previous_feature_index = feature_index
          previous_multi_index = multi_part_index_coord
          prev_geom_index = geometry_index
          segment_index = 0
          next
        end

        segment = Turf.line_string([previous_coords, current_coord], feature[:properties])
        next unless yield(segment, feature_index, multi_feature_index, geometry_index, segment_index)

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

  # Iterate over properties in any GeoJSON object, similar to Array.forEach.
  # @see https://turfjs.org/docs/#propEach
  # @param geojson [FeatureCollection|Feature] any GeoJSON object
  # @yieldparam current_properties [Hash] The current Properties being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  def prop_each(geojson)
    case geojson[:type]
    when "FeatureCollection"
      geojson[:features].each_with_index do |feature, i|
        break if yield(feature[:properties], i) == false
      end
    when "Feature"
      yield(geojson[:properties], 0)
    end
  end

  # Reduce properties in any GeoJSON object into a single value,
  # similar to how Array.reduce works. However, in this case we lazily run
  # the reduction, so an array of all properties is unnecessary.
  # @see https://turfjs.org/docs/#propReduce
  # @param geojson [FeatureCollection|Feature|Geometry] any GeoJSON object
  # @param initial_value [Object] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [Object] The accumulated value previously returned in the last invocation
  # of the callback, or initial_value, if supplied.
  # @yieldparam current_properties [Hash] The current Properties being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed.
  # @return [Object] The value that results from the reduction.
  def prop_reduce(geojson, initial_value = nil)
    previous_value = initial_value

    prop_each(geojson) do |current_properties, feature_index|
      previous_value = if feature_index.zero? && initial_value.nil?
                         current_properties
                       else
                         yield(previous_value, current_properties, feature_index)
                       end
    end

    previous_value
  end

  # Iterate over line or ring coordinates in LineString, Polygon, MultiLineString, MultiPolygon Features or Geometries,
  # similar to Array.forEach.
  # @see https://turfjs.org/docs/#lineEach
  # @param geojson [FeatureCollection<Lines>|Feature<Lines>|Lines|Feature<GeometryCollection>|GeometryCollection]
  # any GeoJSON object
  # @yieldparam current_line [Feature<LineString>] The current LineString|LinearRing being processed
  # @yieldparam feature_index [number] The current index of the Feature being processed
  # @yieldparam multi_feature_index [number] The current index of the Multi-Feature being processed
  # @yieldparam geometry_index [number] The current index of the Geometry being processed
  def line_each(geojson)
    flatten_each(geojson) do |feature, feature_index, multi_feature_index|
      next unless feature[:geometry]

      type = feature[:geometry][:type]
      coords = feature[:geometry][:coordinates]

      case type
      when "LineString"
        yield(feature, feature_index, multi_feature_index, 0, 0)
      when "Polygon"
        coords.each_with_index do |ring, geometry_index|
          yield(
            feature({ type: "LineString", coordinates: ring }, feature[:properties]),
            feature_index,
            multi_feature_index,
            geometry_index
          )
        end
      end
    end
  end

  # Reduce features in any GeoJSON object, similar to Array.reduce().
  # @see https://turfjs.org/docs/#lineReduce
  # @param geojson [FeatureCollection<Lines>|Feature<Lines>|Lines|Feature<GeometryCollection>|GeometryCollection]
  # any GeoJSON object
  # @param initial_value [Object] Value to use as the first argument to the first call of the callback.
  # @yieldparam previous_value [Object] The accumulated value previously returned in the last invocation
  # of the callback, or initial_value, if supplied.
  # @yieldparam current_line [Feature<LineString>] The current LineString|LinearRing being processed.
  # @yieldparam feature_index [number] The current index of the Feature being processed
  # @yieldparam multi_feature_index [number] The current index of the Multi-Feature being processed
  # @yieldparam geometry_index [number] The current index of the Geometry being processed
  # @return [Object] The value that results from the reduction.
  def line_reduce(geojson, initial_value = nil)
    previous_value = initial_value

    line_each(geojson) do |current_line, feature_index, multi_feature_index, geometry_index|
      previous_value = if feature_index.zero? && initial_value.nil?
                         current_line
                       else
                         yield(previous_value, current_line, feature_index, multi_feature_index, geometry_index)
                       end
    end

    previous_value
  end

  def find_segment(*args)
  end

  def find_point(*args)
  end
end
