# frozen_string_literal: true

require_relative "helpers"

# :nodoc:
module Turf
  # @!group Meta

  # Unwrap a coordinate from a Point Feature, Geometry or a single coordinate.
  # @see https://turfjs.org/docs/#getCoord
  # @param coord [Array|Geometry<Point>|Feature<Point>] GeoJSON Point or an Array of numbers
  # @return [Array] coordinates
  def get_coord(coord)
    if !coord
      raise Error, "coord is required"
    end

    is_numeric = ->(i) { i.is_a? Numeric }
    if coord.is_a?(Array) && coord.length >= 2 && coord.all?(&is_numeric)
      return coord
    end

    if coord.is_a? Hash
      coord = deep_symbolize_keys(coord)

      is_feature = coord[:type] == "Feature"
      if is_feature && coord.dig(:geometry, :type) == "Point"
        return coord[:geometry][:coordinates]
      end

      if coord[:type] == "Point"
        return coord[:coordinates]
      end
    end

    raise Error, "coord must be GeoJSON Point or an Array of numbers"
  end

  # Get Geometry from Feature or Geometry Object
  # @see https://turfjs.org/docs/#getGeom
  # @param geojson [Feature|Geometry] GeoJSON Feature or Geometry Object
  # @return [Geometry|null] GeoJSON Geometry Object
  def get_geom(geojson)
    geojson = deep_symbolize_keys geojson
    return geojson[:geometry] if geojson[:type] == "Feature"

    geojson
  end

  # Unwrap coordinates from a Feature, Geometry Object or an Array
  # @see https://turfjs.org/docs/#getCoords
  # @param coords [Array|Geometry|Feature] Feature, Geometry Object or an Array
  # @return [Array] coordinates
  def get_coords(coords)
    if coords.is_a?(Array)
      return coords
    end

    coords = deep_symbolize_keys coords

    # Feature
    if coords.is_a?(Hash) && coords[:type] == "Feature"
      if coords[:geometry]
        return coords[:geometry][:coordinates]
      end
    elsif coords.is_a?(Hash) && coords[:coordinates]
      # Geometry
      return coords[:coordinates]
    end

    raise Error, "coords must be GeoJSON Feature, Geometry Object or an Array"
  end

  # Checks if coordinates contains a number
  # @see https://turfjs.org/docs/#containsNumber
  # @param coordinates [Array] GeoJSON Coordinates
  # @return [Boolean] true if Array contains a number
  def contains_number(coordinates)
    if coordinates.length > 1 && coordinates[0].is_a?(Numeric) && coordinates[1].is_a?(Numeric)
      return true
    end

    if coordinates[0].is_a?(Array) && !coordinates[0].empty?
      return contains_number(coordinates[0])
    end

    raise Error, "coordinates must only contain numbers"
  end

  # Enforce expectations about types of GeoJSON objects for Turf.
  # @see https://turfjs.org/docs/#geojsonType
  # @param value [GeoJSON] any GeoJSON object
  # @param type [String] expected GeoJSON type
  # @param name [String] name of calling function
  # @raise [Error] if value is not the expected type.
  def geojson_type(value = nil, type = nil, name = nil)
    if !type || !name
      raise Error, "type and name required"
    end

    return unless !value || value[:type] != type

    raise Error, "Invalid input to #{name}: must be a #{type}, given #{value[:type]}"
  end

  # Enforce expectations about types of Feature inputs for Turf.
  # @see https://turfjs.org/docs/#featureOf
  # @param feature [Feature] a feature with an expected geometry type
  # @param type [String] expected GeoJSON type
  # @param name [String] name of calling function
  # @raise [Error] error if value is not the expected type.
  def feature_of(feature = nil, type = nil, name = nil)
    if !feature
      raise Error, "No feature passed"
    end
    if !name
      raise Error, ".featureOf() requires a name"
    end
    if !feature || feature[:type] != "Feature" || !feature[:geometry]
      raise Error, "Invalid input to #{name}, Feature with geometry required"
    end
    return unless feature[:geometry][:type] != type

    raise Error, "Invalid input to #{name}: must be a #{type}, given #{feature[:geometry][:type]}"
  end

  # Enforce expectations about types of FeatureCollection inputs for Turf.
  # @see https://turfjs.org/docs/#collectionOf
  # @param feature_collection [FeatureCollection] a FeatureCollection for which features will be judged
  # @param type [String] expected GeoJSON type
  # @param name [String] name of calling function
  # @raise [Error] if value is not the expected type.
  def collection_of(feature_collection, type, name = nil)
    if !feature_collection
      raise Error, "No featureCollection passed"
    end
    if !name
      raise Error, ".collectionOf() requires a name"
    end
    if feature_collection[:type] != "FeatureCollection"
      raise Error, "Invalid input to #{name}, FeatureCollection required"
    end

    feature_collection[:features].each do |feature|
      if !feature || feature[:type] != "Feature" || !feature[:geometry]
        raise Error, "Invalid input to #{name}, Feature with geometry required"
      end
      if feature[:geometry][:type] != type
        raise Error, "Invalid input to #{name}: must be a #{type}, given #{feature[:geometry][:type]}"
      end
    end
  end

  # Get GeoJSON object's type, Geometry type is prioritize.
  # @see https://turfjs.org/docs/#getType
  # @param geojson [GeoJSON] GeoJSON object
  # @param _name [String] name of the variable to display in error message (unused)
  # @return [String] GeoJSON type
  def get_type(geojson, _name = "geojson")
    geojson = deep_symbolize_keys geojson
    if geojson[:type] == "FeatureCollection"
      return "FeatureCollection"
    end
    if geojson[:type] == "GeometryCollection"
      return "GeometryCollection"
    end
    if geojson[:type] == "Feature" && geojson[:geometry]
      return geojson[:geometry][:type]
    end

    geojson[:type]
  end
end
