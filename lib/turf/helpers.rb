# frozen_string_literal: true

module Turf
  EARTH_RADIUS = 6_371_008.8
  private_constant :EARTH_RADIUS
  FACTORS = {
    "centimeters" => EARTH_RADIUS * 100,
    "centimetres" => EARTH_RADIUS * 100,
    "degrees" => EARTH_RADIUS / 111_325,
    "feet" => EARTH_RADIUS * 3.28084,
    "inches" => EARTH_RADIUS * 39.370,
    "kilometers" => EARTH_RADIUS / 1000,
    "kilometres" => EARTH_RADIUS / 1000,
    "meters" => EARTH_RADIUS,
    "metres" => EARTH_RADIUS,
    "miles" => EARTH_RADIUS / 1609.344,
    "millimeters" => EARTH_RADIUS * 1000,
    "millimetres" => EARTH_RADIUS * 1000,
    "nauticalmiles" => EARTH_RADIUS / 1852,
    "radians" => 1,
    "yards" => EARTH_RADIUS / 1.0936
  }.freeze
  private_constant :FACTORS

  # @!group Helper

  # Wraps a GeoJSON Geometry in a GeoJSON Feature.
  # @see https://turfjs.org/docs/#feature
  # @param geom [Geometry] input geometry
  # @param properties [Hash] an Object of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature] a GeoJSON Feature
  def feature(geom, properties = {}, bbox: nil, id: nil)
    feat = {
      type: "Feature",
      geometry: geom,
      properties: properties
    }
    feat[:id] = options[:id] if id
    feat[:bbox] = options[:bbox] if bbox

    feat
  end

  # Takes one or more Features and creates a FeatureCollection.
  # @see https://turfjs.org/docs/#featureCollection
  # @param features [Array<Feature>] input features
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [FeatureCollection] FeatureCollection of Features
  def feature_collection(features, bbox: nil, id: nil)
    fc = { type: "FeatureCollection" }
    fc[:id] = options[:id] if id
    fc[:bbox] = options[:bbox] if bbox
    fc[:features] = features

    fc
  end

  # Creates a LineString Feature from an Array of Positions.
  # @see https://turfjs.org/docs/#lineString
  # @param coordinates [Array<Array<number>>] an array of Positions
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature<LineString>] LineString Feature
  def line_string(coordinates, properties = {}, bbox: nil, id: nil)
    if coordinates.size < 2
      raise Error, "coordinates must be an array of two or more positions"
    end

    geom = {
      type: "LineString",
      coordinates: coordinates
    }
    feature(geom, properties, bbox: bbox, id: id)
  end

  # Creates a Point Feature from a Position.
  # @see https://turfjs.org/docs/#point
  # @param coordinates [Array<number>] longitude, latitude position (each in decimal degrees)
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature<Point>] a Point feature
  def point(coordinates, properties = {}, id: nil, bbox: nil)
    geom = {
      type: "Point",
      coordinates: coordinates
    }
    feature(geom, properties, id: id, bbox: bbox)
  end

  # Creates a Polygon Feature from an Array of LinearRings.
  # @see https://turfjs.org/docs/#polygon
  # @param coordinates [Array<Array<Array<number>>>] an array of LinearRings
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature<Polygon>] Polygon feature
  def polygon(coordinates, properties = {}, bbox: nil, id: nil)
    coordinates.each do |ring|
      if ring.size < 4
        raise(
          Error,
          "Each LinearRing of a Polygon must have 4 or more Positions.",
        )
      end

      ring.last.each_with_index do |number, idx|
        if ring.first[idx] != number
          raise Error, "First and last Position are not equivalent."
        end
      end
    end
    geom = {
      type: "Polygon",
      coordinates: coordinates
    }
    feature(geom, properties, id: id, bbox: bbox)
  end

  # @!group Unit Conversion

  def radians_to_degrees(radians)
    degrees = radians.remainder(2 * Math::PI)
    degrees * 180 / Math::PI
  end

  def degrees_to_radians(degrees)
    radians = degrees.remainder(360)
    radians * Math::PI / 180
  end

  def radians_to_length(radians, units = "kilometers")
    factor = FACTORS[units]
    raise Error, "#{units} units is invalid" unless factor

    radians * factor
  end

  def length_to_radians(distance, units = "kilometers")
    factor = FACTORS[units]
    raise Error, "#{units} units is invalid" unless factor

    distance / factor
  end
end
