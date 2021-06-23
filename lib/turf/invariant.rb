# frozen_string_literal: true

#:nodoc:
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
      if is_feature && coord.fetch(:geometry, {})[:type] == "Point"
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
end
