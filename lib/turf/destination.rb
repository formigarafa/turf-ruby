# frozen_string_literal: true

module Turf
  module Measurement
    def destination(origin, distance, bearing, **options)
      coordinates1 = get_coord origin
      longitude1 = degrees_to_radians coordinates1[0]
      latitude1 = degrees_to_radians coordinates1[1]
      bearing_radians = degrees_to_radians bearing
      radians = length_to_radians distance, options[:units]

      latitude2 = Math.asin(Math.sin(latitude1) * Math.cos(radians) +
        Math.cos(latitude1) * Math.sin(radians) * Math.cos(bearing_radians))
      longitude2 = longitude1 + Math.atan2(
        Math.sin(bearing_radians) * Math.sin(radians) * Math.cos(latitude1),
        Math.cos(radians) - Math.sin(latitude1) * Math.sin(latitude2),
      )
      lng = radians_to_degrees(longitude2)
      lat = radians_to_degrees(latitude2)

      point([lng, lat], options[:properties])
    end
  end
end
