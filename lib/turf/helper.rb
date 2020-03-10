# frozen_string_literal: true

module Turf
  EARTH_RADIUS = 6371008.8
  FACTORS = {
    "centimeters" => EARTH_RADIUS * 100,
    "centimetres" => EARTH_RADIUS * 100,
    "degrees" => EARTH_RADIUS / 111325,
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
    "yards" => EARTH_RADIUS / 1.0936,
  }.freeze

  def self.feature(geom, properties = nil, options = {})
    feat = {
      type: "Feature",
      geometry: geom,
      properties: properties || {},
    }
    feat[:id] = options[:id] if options[:id]

    feat[:bbox] = options[:bbox] if options[:bbox]

    feat
  end

  def self.line_string(coordinates, properties = nil, options = {})
    if coordinates.size < 2
      raise Error, "coordinates must be an array of two or more positions"
    end

    geom = {
      type: "LineString",
      coordinates: coordinates,
    }
    feature(geom, properties, options)
  end

  def self.point(coordinates, properties = nil, options = {})
    geom = {
      type: "Point",
      coordinates: coordinates,
    }
    feature(geom, properties, options)
  end

  def self.polygon(coordinates, properties = nil, options = {})
    coordinates.each do |ring|
      if ring.size < 4
        raise Error, "Each LinearRing of a Polygon must have 4 or more Positions."
      end

      ring.last.each_with_index do |number, idx|
        if ring.first[idx] != number
          raise Error, "First and last Position are not equivalent."
        end
      end
    end
    geom = {
      type: "Polygon",
      coordinates: coordinates,
    }
    feature(geom, properties, options)
  end

  def self.units(units)
    raise Error, "invalid units: #{units}" \
      unless [
        "meters", "millimeters", "centimeters",
        "kilometers", "acres", "miles", "nauticalmiles",
        "inches", "yards", "feet", "radians", "degrees"
      ].include?(units)

    units
  end

  def self.degrees_to_radians(degrees)
    radians = degrees.remainder(360)
    radians * Math::PI / 180
  end

  def self.radians_to_length(radians, units = "kilometers")
    factor = FACTORS[units(units)]
    raise "#{units} units is invalid" unless factor

    radians * factor
  end

  def self.length_to_radians(distance, units = "kilometers")
    factor = FACTORS[units(units)]
    raise "#{units} units is invalid" unless factor

    distance / factor
  end
end
