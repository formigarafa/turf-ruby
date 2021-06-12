# frozen_string_literal: true

module Turf
  module Measurement
    def bearing(from, to, **options)
      return calculate_final_bearing(from, to) if options[:final] == true

      coordinates1 = get_coord from
      coordinates2 = get_coord to

      lon1 = degrees_to_radians(coordinates1[0])
      lon2 = degrees_to_radians(coordinates2[0])
      lat1 = degrees_to_radians(coordinates1[1])
      lat2 = degrees_to_radians(coordinates2[1])
      a = Math.sin(lon2 - lon1) * Math.cos(lat2)
      b = Math.cos(lat1) * Math.sin(lat2) -
          Math.sin(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1)

      radians_to_degrees(Math.atan2(a, b))
    end

    private

    def calculate_final_bearing(from, to)
      bear = bearing(to, from)
      (bear + 180) % 360
    end
  end
end
