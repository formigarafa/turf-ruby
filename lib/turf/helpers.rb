# frozen_string_literal: true

# :nodoc:
module Turf
  EARTH_RADIUS = 6_371_008.8
  private_constant :EARTH_RADIUS
  FACTORS = {
    "centimeters" => EARTH_RADIUS * 100,
    "centimetres" => EARTH_RADIUS * 100,
    "degrees" => 360.0 / (2 * Math::PI),
    "feet" => EARTH_RADIUS * 3.28084,
    "inches" => EARTH_RADIUS * 39.37,
    "kilometers" => EARTH_RADIUS / 1000,
    "kilometres" => EARTH_RADIUS / 1000,
    "meters" => EARTH_RADIUS,
    "metres" => EARTH_RADIUS,
    "miles" => EARTH_RADIUS / 1609.344,
    "millimeters" => EARTH_RADIUS * 1000,
    "millimetres" => EARTH_RADIUS * 1000,
    "nauticalmiles" => EARTH_RADIUS / 1852,
    "radians" => 1.0,
    "yards" => EARTH_RADIUS * 1.0936
  }.freeze
  private_constant :FACTORS

  AREA_FACTORS = {
    "acres" => 0.000247105,
    "centimeters" => 10_000.0,
    "centimetres" => 10_000.0,
    "feet" => 10.763910417,
    "hectares" => 0.0001,
    "inches" => 1550.003100006,
    "kilometers" => 0.000001,
    "kilometres" => 0.000001,
    "meters" => 1.0,
    "metres" => 1.0,
    "miles" => 3.86e-7,
    "nauticalmiles" => 2.9155334959812285e-7,
    "millimeters" => 1_000_000.0,
    "millimetres" => 1_000_000.0,
    "yards" => 1.195990046
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
  def feature(geom, properties = nil, options = {})
    feat = {
      type: "Feature",
      properties: properties || {},
      geometry: geom
    }
    feat[:id] = options[:id] if options[:id]
    feat[:bbox] = options[:bbox] if options[:bbox]

    feat
  end

  # Takes one or more Features and creates a FeatureCollection.
  # @see https://turfjs.org/docs/#featureCollection
  # @param features [Array<Feature>] input features
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [FeatureCollection] FeatureCollection of Features
  def feature_collection(features, options = {})
    fc = { type: "FeatureCollection" }
    fc[:id] = options[:id] if options[:id]
    fc[:bbox] = options[:bbox] if options[:bbox]
    fc[:features] = features

    fc
  end

  # Creates a Feature based on a coordinate array. Properties can be added optionally.
  # @see https://turfjs.org/docs/#geometryCollection
  # @param geometries [Array<Geometry>] an array of GeoJSON Geometries
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string|number] Identifier associated with the Feature
  # @return [Feature<GeometryCollection>] a GeoJSON GeometryCollection Feature
  def geometry_collection(geometries, properties = nil, options = {})
    geom = {
      type: "GeometryCollection",
      geometries: geometries
    }

    feature(geom, properties, options)
  end

  # Creates a Feature based on a coordinate array. Properties can be added optionally.
  # @param coordinates [Array<Array<number>>] an array of Positions
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string|number] Identifier associated with the Feature
  # @return [Feature<MultiPoint>] a MultiPoint feature
  def multi_point(coordinates, properties = nil, options = {})
    geom = {
      type: "MultiPoint",
      coordinates: coordinates
    }

    feature(geom, properties, options)
  end

  # Creates a LineString Feature from an Array of Positions.
  # @see https://turfjs.org/docs/#lineString
  # @param coordinates [Array<Array<number>>] an array of Positions
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string|number] Identifier associated with the Feature
  # @return [Feature<LineString>] LineString Feature
  def line_string(coordinates, properties = nil, options = {})
    if coordinates.size < 2
      raise Error, "coordinates must be an array of two or more positions"
    end

    geom = {
      type: "LineString",
      coordinates: coordinates
    }
    feature(geom, properties, options)
  end

  # Creates a Point Feature from a Position.
  # @see https://turfjs.org/docs/#point
  # @param coordinates [Array<number>] longitude, latitude position (each in decimal degrees)
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature<Point>] a Point feature
  def point(coordinates, properties = nil, options = {})
    geom = {
      type: "Point",
      coordinates: coordinates
    }
    feature(geom, properties, options)
  end

  # Creates a Polygon Feature from an Array of LinearRings.
  # @see https://turfjs.org/docs/#polygon
  # @param coordinates [Array<Array<Array<number>>>] an array of LinearRings
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string | number] Identifier associated with the Feature
  # @return [Feature<Polygon>] Polygon feature
  def polygon(coordinates, properties = nil, options = {})
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
    feature(geom, properties, options)
  end

  # Creates a Feature<MultiPolygon> based on a coordinate array. Properties can be added optionally.
  # @see https://turfjs.org/docs/#multiPolygon
  # @param coordinates [Array<Array<Array<Array<number>>>>] an array of Polygons
  # @param properties [Hash] an Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string|number] Identifier associated with the Feature
  # @return [Feature<MultiPolygon>] a multipolygon feature
  def multi_polygon(coordinates, properties = nil, options = {})
    geom = {
      type: "MultiPolygon",
      coordinates: coordinates
    }
    feature(geom, properties, options)
  end

  # Creates a Feature<MultiLineString> based on a coordinate array. Properties can be added optionally.
  # @see https://turfjs.org/docs/#multiLineString
  # @param coordinates [Array<Array<Array<number>>>] coordinates an array of LineStrings
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the Feature
  # @param id [string|number] Identifier associated with the Feature
  # @return [Feature<MultiLineString>] a MultiLineString feature
  def multi_line_string(coordinates, properties = nil, options = {})
    geom = {
      type: "MultiLineString",
      coordinates: coordinates
    }
    feature(geom, properties, options)
  end

  # @!group Unit Conversion

  # Converts an angle in radians to degrees
  # @see https://turfjs.org/docs/#radiansToDegrees
  # @param radians [number] angle in radians
  # @return [number] degrees between 0 and 360 degrees
  def radians_to_degrees(radians)
    degrees = radians.remainder(2 * Math::PI)
    degrees * 180 / Math::PI
  end

  # Converts an angle in degrees to radians
  # @see https://turfjs.org/docs/#degreesToRadians
  # @param degrees [number] angle between 0 and 360 degrees
  # @return [number] angle in radians
  def degrees_to_radians(degrees)
    radians = degrees.remainder(360)
    radians * Math::PI / 180
  end

  # Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit. Valid units:
  # miles, nauticalmiles, inches, yards, meters, metres, kilometers, centimeters, feet
  # @see https://turfjs.org/docs/#radiansToLength
  # @param radians [number] in radians across the sphere
  # @param units [string] can be degrees, radians, miles, inches, yards, metres, meters, kilometres, kilometers.
  # @return [number] distance
  def radians_to_length(radians, units = nil)
    units ||= "kilometers"
    factor = FACTORS[units]
    raise Error, "#{units} units is invalid" unless factor

    radians * factor
  end

  # Convert a distance measurement (assuming a spherical Earth) from a real-world unit into radians Valid units: miles,
  # nauticalmiles, inches, yards, meters, metres, kilometers, centimeters, feet
  # @see https://turfjs.org/docs/#lengthToRadians
  # @param distance [number] in real units
  # @param units [string] can be degrees, radians, miles, inches, yards, metres, meters, kilometres, kilometers.
  # @return [number] radians
  def length_to_radians(distance, units = nil)
    units ||= "kilometers"
    factor = FACTORS[units]
    raise Error, "#{units} units is invalid" unless factor

    distance / factor
  end

  # Creates a FeatureCollection from an Array of LineString coordinates.
  # @see https://turfjs.org/docs/#lineStrings
  # @param coordinates [Array<Array<Array<number>>>] an array of LinearRings
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the FeatureCollection
  # @param id [string|number] Identifier associated with the FeatureCollection
  # @return [FeatureCollection<LineString>] LineString FeatureCollection
  def line_strings(coordinates, properties = nil, options = {})
    features = coordinates.map { |coords| line_string(coords, properties) }
    feature_collection(features, options)
  end

  # Creates a Point FeatureCollection from an Array of Point coordinates.
  # @see https://turfjs.org/docs/#points
  # @param coordinates [Array<Array<number>>] an array of Points
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the FeatureCollection
  # @param id [string|number] Identifier associated with the FeatureCollection
  # @return [FeatureCollection<Point>] Point FeatureCollection
  def points(coordinates, properties = nil, options = {})
    features = coordinates.map { |coords| point(coords, properties) }
    feature_collection(features, options)
  end

  # Creates a Polygon FeatureCollection from an Array of Polygon coordinates.
  # @see https://turfjs.org/docs/#polygons
  # @param coordinates [Array<Array<Array<Array<number>>>>] an array of Polygon coordinates
  # @param properties [Hash] a Hash of key-value pairs to add as properties
  # @param bbox [Array<number>] Bounding Box Array [west, south, east, north] associated with the FeatureCollection
  # @param id [string|number] Identifier associated with the FeatureCollection
  # @return [FeatureCollection<Polygon>] Polygon FeatureCollection
  def polygons(coordinates, properties = nil, options = {})
    features = coordinates.map { |coords| polygon(coords, properties) }
    feature_collection(features, options)
  end

  # Checks if the input is a number.
  # @see https://turfjs.org/docs/#isNumber
  # @param num [Object] Number to validate
  # @return [boolean] true/false
  def is_number(num)
    num.is_a?(Numeric)
  end

  # Checks if the input is an object.
  # @see https://turfjs.org/docs/#isObject
  # @param input [Object] variable to validate
  # @return [boolean] true/false, including false for Arrays and Functions
  def is_object(input)
    input.is_a?(Hash) && !input.is_a?(Array)
  end

  # Converts any azimuth angle from the north line direction (positive clockwise)
  # and returns an angle between -180 and +180 degrees (positive clockwise), 0 being the north line
  # @see https://turfjs.org/docs/#azimuthToBearing
  # @param angle [number] between 0 and 360 degrees
  # @return [number] bearing between -180 and +180 degrees
  def azimuth_to_bearing(angle)
    angle = angle.remainder(360)
    angle -= 360 if angle > 180
    angle += 360 if angle < -180
    angle
  end

  # Converts any bearing angle from the north line direction (positive clockwise)
  # and returns an angle between 0-360 degrees (positive clockwise), 0 being the north line
  # @see https://turfjs.org/docs/#bearingToAzimuth
  # @param bearing [number] angle, between -180 and +180 degrees
  # @return [number] angle between 0 and 360 degrees
  def bearing_to_azimuth(bearing)
    angle = bearing.remainder(360)
    angle += 360 if angle < 0
    angle
  end

  # Rounds a number to a specified precision
  # @see https://turfjs.org/docs/#round
  # @param num [number] Number to round
  # @param precision [number] Precision
  # @return [number] rounded number
  def round(num, precision = 0)
    if !precision.is_a?(Numeric) || precision < 0
      raise Error, "invalid precision"
    end

    num.round(precision)
  end

  # Converts an area from one unit to another.
  # @see https://turfjs.org/docs/#convertArea
  # @param area [number] Area to be converted
  # @param original_unit [string] Input area unit
  # @param final_unit [string] Returned area unit
  # @return [number] The converted length
  def convert_area(area, original_unit = nil, final_unit = nil)
    original_unit ||= "meters"
    final_unit ||= "kilometers"

    raise Error, "area must be a positive number" unless area >= 0

    start_factor = AREA_FACTORS[original_unit]
    raise Error, "invalid original units" unless start_factor

    final_factor = AREA_FACTORS[final_unit]
    raise Error, "invalid final units" unless final_factor

    (area / start_factor) * final_factor
  end

  # Converts a length from one unit to another.
  # @see https://turfjs.org/docs/#convertLength
  # @param length [number] Length to be converted
  # @param original_unit [string] Input length unit
  # @param final_unit [string] Returned length unit
  # @return [number] The converted length
  def convert_length(length, original_unit = nil, final_unit = nil)
    original_unit ||= "kilometers"
    final_unit ||= "kilometers"

    raise Error, "length must be a positive number" unless length >= 0

    radians_to_length(length_to_radians(length, original_unit), final_unit)
  end
end
