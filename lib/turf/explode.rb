# frozen_string_literal: true

require_relative "meta"
require_relative "helpers"

# :nodoc:
module Turf
  def explode(geojson)
    points = []

    if geojson[:type] == "FeatureCollection"
      feature_each(geojson) do |feature|
        coord_each(feature) do |coord|
          points << point(coord, feature[:properties])
        end
      end
    elsif geojson[:type] == "Feature"
      coord_each(geojson) do |coord|
        points << point(coord, geojson[:properties])
      end
    else
      coord_each(geojson) do |coord|
        points << point(coord)
      end
    end

    feature_collection(points)
  end
end
