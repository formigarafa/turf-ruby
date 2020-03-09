# frozen_string_literal: true

module Turf
  def self.get_coord(coord)
    coord = deep_symbolize_keys(coord)
    return coord \
      if coord.is_a?(Array) && \
        coord.length >= 2 && \
        !coord[0].is_a?(Array) && \
        !coord[1].is_a?(Array)

    return coord.fetch(:geometry).fetch(:coordinates) \
      if coord[:type] == "Feature" && \
        coord.fetch(:geometry)[:type] === "Point"

    return coord.fetch(:coordinates) if coord[:type] == "Point"

    raise "coord must be GeoJSON Point or an Array of numbers"
  end
end
