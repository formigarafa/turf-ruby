# frozen_string_literal: true

require "test_helper"

class TurfBooleanPointInPolygonTest < Minitest::Test
  # https://github.com/Turfjs/turf/blob/master/packages/turf-boolean-point-in-polygon/test.js
  def test_feature_collection
    # test for a simple polygon
    poly = Turf.polygon([[[0, 0], [0, 100], [100, 100], [100, 0], [0, 0]]])
    pt_in = Turf.point([50, 50])
    pt_out = Turf.point([140, 150])

    assert_equal(Turf.boolean_point_in_polygon(pt_in, poly), true)
    assert_equal(Turf.boolean_point_in_polygon(pt_out, poly), false)

    # test for a concave polygon

    concave_poly = Turf.polygon(
      [
        [
          [0, 0], [50, 50], [0, 100], [100, 100], [100, 0], [0, 0],
        ],
      ],
    )
    pt_concave_in = Turf.point([75, 75])
    pt_concave_out = Turf.point([25, 50])

    assert_equal(
      Turf.boolean_point_in_polygon(pt_concave_in, concave_poly),
      true,
      "point inside concave polygon",
    )
    assert_equal(
      Turf.boolean_point_in_polygon(pt_concave_out, concave_poly),
      false,
      "point outside concave polygon",
    )
  end

  def test_poly_with_hole
    pt_in_hole = Turf.point([-86.69208526611328, 36.20373274711739])
    pt_in_poly = Turf.point([-86.72229766845702, 36.20258997094334])
    pt_outside_poly = Turf.point([-86.75079345703125, 36.18527313913089])
    poly_hole = load_geojson("boolean_point_in_polygon/poly-with-hole.geojson")

    assert_equal(Turf.boolean_point_in_polygon(pt_in_hole, poly_hole), false)
    assert_equal(Turf.boolean_point_in_polygon(pt_in_poly, poly_hole), true)
    assert_equal(
      Turf.boolean_point_in_polygon(pt_outside_poly, poly_hole),
      false,
    )
  end

  def test_multipolygon_with_hole
    pt_in_hole = Turf.point([-86.69208526611328, 36.20373274711739])
    pt_in_poly = Turf.point([-86.72229766845702, 36.20258997094334])
    pt_in_poly2 = Turf.point([-86.75079345703125, 36.18527313913089])
    pt_outside_poly = Turf.point([-86.75302505493164, 36.23015046460186])
    multi_poly_hole = load_geojson(
      "boolean_point_in_polygon/multipoly-with-hole.geojson",
    )

    assert_equal(
      Turf.boolean_point_in_polygon(pt_in_hole, multi_poly_hole),
      false,
    )
    assert_equal(
      Turf.boolean_point_in_polygon(pt_in_poly, multi_poly_hole),
      true,
    )
    assert_equal(
      Turf.boolean_point_in_polygon(pt_in_poly2, multi_poly_hole),
      true,
    )
    assert_equal(
      Turf.boolean_point_in_polygon(pt_in_poly, multi_poly_hole),
      true,
    )
    assert_equal(
      Turf.boolean_point_in_polygon(pt_outside_poly, multi_poly_hole),
      false,
    )
  end

  def test_boundary_test
    poly1 = Turf.polygon(
      [
        [
          [10, 10],
          [30, 20],
          [50, 10],
          [30, 0],
          [10, 10],
        ],
      ],
    )
    poly2 = Turf.polygon(
      [
        [
          [10, 0],
          [30, 20],
          [50, 0],
          [30, 10],
          [10, 0],
        ],
      ],
    )
    poly3 = Turf.polygon(
      [
        [
          [10, 0],
          [30, 20],
          [50, 0],
          [30, -20],
          [10, 0],
        ],
      ],
    )
    poly4 = Turf.polygon(
      [
        [
          [0, 0],
          [0, 20],
          [50, 20],
          [50, 0],
          [40, 0],
          [30, 10],
          [30, 0],
          [20, 10],
          [10, 10],
          [10, 0],
          [0, 0],
        ],
      ],
    )
    poly5 = Turf.polygon(
      [
        [
          [0, 20],
          [20, 40],
          [40, 20],
          [20, 0],
          [0, 20],
        ],
        [
          [10, 20],
          [20, 30],
          [30, 20],
          [20, 10],
          [10, 20],
        ],
      ],
    )

    [true, false].each do |ignore_boundary|
      is_boundary_included = !ignore_boundary
      tests = [
        [poly1, Turf.point([10, 10]), is_boundary_included], # 0
        [poly1, Turf.point([30, 20]), is_boundary_included],
        [poly1, Turf.point([50, 10]), is_boundary_included],
        [poly1, Turf.point([30, 10]), true],
        [poly1, Turf.point([0, 10]), false],
        [poly1, Turf.point([60, 10]), false],
        [poly1, Turf.point([30, -10]), false],
        [poly1, Turf.point([30, 30]), false],
        [poly2, Turf.point([30,  0]), false],
        [poly2, Turf.point([0, 0]), false],
        [poly2, Turf.point([60, 0]), false], # 10
        [poly3, Turf.point([30, 0]), true],
        [poly3, Turf.point([0,  0]), false],
        [poly3, Turf.point([60, 0]), false],
        [poly4, Turf.point([0, 20]), is_boundary_included],
        [poly4, Turf.point([10, 20]), is_boundary_included],
        [poly4, Turf.point([50, 20]), is_boundary_included],
        [poly4, Turf.point([0, 10]), is_boundary_included],
        [poly4, Turf.point([5, 10]), true],
        [poly4, Turf.point([25, 10]), true],
        [poly4, Turf.point([35, 10]), true], # 20
        [poly4, Turf.point([0, 0]), is_boundary_included],
        [poly4, Turf.point([20,  0]), false],
        [poly4, Turf.point([35,  0]), false],
        [poly4, Turf.point([50,  0]), is_boundary_included],
        [poly4, Turf.point([50, 10]), is_boundary_included],
        [poly4, Turf.point([5,  0]), is_boundary_included],
        [poly4, Turf.point([10,  0]), is_boundary_included],
        [poly5, Turf.point([20, 30]), is_boundary_included],
        [poly5, Turf.point([25, 25]), is_boundary_included],
        [poly5, Turf.point([30, 20]), is_boundary_included], # 30
        [poly5, Turf.point([25, 15]), is_boundary_included],
        [poly5, Turf.point([20, 10]), is_boundary_included],
        [poly5, Turf.point([15, 15]), is_boundary_included],
        [poly5, Turf.point([10, 20]), is_boundary_included],
        [poly5, Turf.point([15, 25]), is_boundary_included],
        [poly5, Turf.point([20, 20]), false],
      ]

      tests.each_with_index do |test, test_index|
        poly, point, expect_result = test
        assert_equal(
          Turf.boolean_point_in_polygon(
            point,
            poly,
            ignore_boundary: ignore_boundary,
          ),
          expect_result,
          "Boundary #{test_index}",
        )
      end
    end
  end

  # https://github.com/Turfjs/turf-inside/issues/15
  def test_issue15
    pt1 = Turf.point([-9.9964077, 53.8040989])
    poly = Turf.polygon(
      [
        [
          [5.080336744095521, 67.89398938540765],
          [0.35070899909145403, 69.32470003971179],
          [-24.453622256504122, 41.146696777884564],
          [-21.6445524714804, 40.43225902006474],
          [5.080336744095521, 67.89398938540765],
        ],
      ],
    )

    assert_equal(Turf.boolean_point_in_polygon(pt1, poly), true)
  end
end
