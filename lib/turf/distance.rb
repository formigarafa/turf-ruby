# frozen_string_literal: true

module Turf
  module Measurement
    def distance(from, to, **options)
      coordinates1 = get_coord from
      coordinates2 = get_coord to

      d_lat = degrees_to_radians coordinates2[1] - coordinates1[1]
      d_lon = degrees_to_radians coordinates2[0] - coordinates1[0]
      lat1 = degrees_to_radians coordinates1[1]
      lat2 = degrees_to_radians coordinates2[1]

      a =
        (
          (Math.sin(d_lat / 2)**2) +
          (Math.sin(d_lon / 2)**2) * Math.cos(lat1) * Math.cos(lat2)
        )

      call_args = [
        2 * Math.atan2(
          Math.sqrt(a),
          Math.sqrt(1 - a),
        ),
      ]
      if options[:units]
        call_args << options[:units]
      end
      public_send(:radians_to_length, *call_args)
    end
  end
end
