# frozen_string_literal: true

require_relative "meta"
require_relative "helpers"

# :nodoc:
module Turf
  # Takes a GeoJSON Feature or FeatureCollection and truncates the precision of the geometry.
  # @param {GeoJSON} geojson any GeoJSON Feature, FeatureCollection, Geometry or GeometryCollection.
  # @param {hash} [options={}] Optional parameters
  # @param {number} [options.precision=6] coordinate decimal precision
  # @param {number} [options.coordinates=3] maximum number of coordinates (primarly used to remove z coordinates)
  # @param {boolean} [options.mutate=false] allows GeoJSON input to be mutated
  # (significant performance increase if true (note statement from js port. not checked in ruby))
  # @returns {GeoJSON} layer with truncated geometry
  # @example
  # var point = turf.point([
  #     70.46923055566859,
  #     58.11088890802906,
  #     1508
  # ])
  # var options = {precision: 3, coordinates: 2}
  # var truncated = turf.truncate(point, options)
  # //=truncated.geometry.coordinates => [70.469, 58.111]
  #
  # //addToMap
  # var addToMap = [truncated]
  # /
  def truncate(geojson, options = {})
    precision = options[:precision] || 6
    coordinates = options[:coordinates] || 3
    mutate = options[:mutate]

    if !geojson
      raise("geojson is required")
    end

    if !mutate
      geojson = deep_dup(geojson)
    end

    # factor = Math.pow(10, precision)
    # geojson[:properties][:truncate] = "done"
    # Truncate Coordinates
    coord_each(geojson) do |coords|
      truncate_coords(coords, precision, coordinates)
    end
    geojson
  end

  def truncate_coords(coords, precision, coordinates)
    # Remove extra coordinates (usually elevation coordinates and more)
    if coords.length > coordinates
      coords.slice!(coordinates..-1)
    end

    # coords.map do |coord|
    #   coord.round(precision)
    # end

    # Truncate coordinate decimals
    (0...coords.length).each do |idx|
      coords[idx] = coords[idx].round(precision)
    end
    coords
  end
end
