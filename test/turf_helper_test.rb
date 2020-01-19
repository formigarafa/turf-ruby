require "test_helper"

require "turf/helper"

class TurfHelperTest < Minitest::Test
  def test_point
    pt_array = Turf.point([5, 10], {name: 'test point'});

    assert_equal(pt_array[:geometry][:coordinates][0], 5);
    assert_equal(pt_array[:geometry][:coordinates][1], 10);
    assert_equal(pt_array[:properties][:name], 'test point');

    no_props = Turf.point([0, 0]);
    assert_equal(no_props[:properties], {}, 'no props becomes {}');
  end
end
