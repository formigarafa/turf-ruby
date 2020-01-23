# frozen_string_literal: true

module Turf
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
end
