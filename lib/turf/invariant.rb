# frozen_string_literal: true

module Turf
  def self.get_coord(coord)
    if !coord
      raise Error, "coord is required"
    end

    if coord.is_a?(Array) && coord.length >= 2 && coord.all?{|i| i.is_a? Numeric }
      return coord
    end

    if coord.is_a? Hash
      coord = deep_symbolize_keys(coord)
      if coord[:type] == "Feature" && coord.fetch(:geometry, {})[:type] === "Point"
        return coord[:geometry][:coordinates]
      end

      if coord[:type] == "Point"
        return coord[:coordinates]
      end
    end

    raise Error, "coord must be GeoJSON Point or an Array of numbers"
  end
end
