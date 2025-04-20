module Turf
  module Lineclip
    # Cohen-Sutherland line clipping algorithm, adapted to efficiently
    # handle polylines rather than just segments.
    def self.lineclip(points, bbox, result = [])
      len = points.length
      code_a = bit_code(points[0], bbox)
      part = []
      a = nil
      b = nil

      (1...len).each do |i|
        a = points[i - 1]
        b = points[i]
        code_b = last_code = bit_code(b, bbox)

        loop do
          if (code_a | code_b).zero?
            # accept
            part << a

            if code_b != last_code
              # segment went outside
              part << b

              if i < len - 1
                # start a new line
                result << part
                part = []
              end
            elsif i == len - 1
              part << b
            end
            break
          elsif (code_a & code_b) != 0
            # trivial reject
            break
          elsif code_a != 0
            # a outside, intersect with clip edge
            a = intersect(a, b, code_a, bbox)
            code_a = bit_code(a, bbox)
          else
            # b outside
            b = intersect(a, b, code_b, bbox)
            code_b = bit_code(b, bbox)
          end
        end

        code_a = last_code
      end

      result << part unless part.empty?

      result
    end

    # Sutherland-Hodgeman polygon clipping algorithm
    def self.polygonclip(points, bbox)
      result = []
      prev = nil
      prev_inside = nil

      # clip against each side of the clip rectangle
      [8, 4, 2, 1].each do |edge|
        result = []
        prev = points.last
        prev_inside = (bit_code(prev, bbox) & edge).zero?

        points.each do |p|
          inside = (bit_code(p, bbox) & edge).zero?

          # if segment goes through the clip window, add an intersection
          result << intersect(prev, p, edge, bbox) if inside != prev_inside

          result << p if inside # add a point if it's inside

          prev = p
          prev_inside = inside
        end

        points = result
        break if points.empty?
      end

      result
    end

    # intersect a segment against one of the 4 lines that make up the bbox
    def self.intersect(a, b, edge, bbox)
      if (edge & 8) != 0
        [a[0] + (((b[0] - a[0]) * (bbox[3] - a[1]).to_f) / (b[1] - a[1])), bbox[3]]
      elsif (edge & 4) != 0
        [a[0] + (((b[0] - a[0]) * (bbox[1] - a[1]).to_f) / (b[1] - a[1])), bbox[1]]
      elsif (edge & 2) != 0
        [bbox[2], a[1] + (((b[1] - a[1]) * (bbox[2] - a[0]).to_f) / (b[0] - a[0]))]
      elsif (edge & 1) != 0
        [bbox[0], a[1] + (((b[1] - a[1]) * (bbox[0] - a[0]).to_f) / (b[0] - a[0]))]
      end
    end

    # bit code reflects the point position relative to the bbox:
    #         left  mid  right
    #    top  1001  1000  1010
    #    mid  0001  0000  0010
    # bottom  0101  0100  0110
    def self.bit_code(p, bbox)
      code = 0
      code |= 1 if p[0] < bbox[0] # left
      code |= 2 if p[0] > bbox[2] # right
      code |= 4 if p[1] < bbox[1] # bottom
      code |= 8 if p[1] > bbox[3] # top
      code
    end
  end
end
