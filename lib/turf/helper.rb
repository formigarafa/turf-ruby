module Turf
  def self.feature(geom, properties = nil, options = {})
    feat = {
      type: "Feature",
      geometry: geom,
      properties: properties || {},
    }
    if options[:id]
      feat[:id] = options[:id]
    end

    if options[:bbox]
      feat[:bbox] = options[:bbox]
    end

    feat
  end

  def self.point(coordinates, properties = nil, options = {})
    geom = {
      type: "Point",
      coordinates: coordinates,
    }
    feature(geom, properties, options)
  end
end
