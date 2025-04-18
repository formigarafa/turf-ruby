# turf-ruby [![Build Status](https://travis-ci.com/formigarafa/turf-ruby.svg?branch=master)](https://travis-ci.com/formigarafa/turf-ruby)

Ruby port of [Turf.js](https://turfjs.org/), an advance geospatial analysis library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'turf-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install turf-ruby

## Usage

Example:

```
# Turf.js uses [GeoJSON](https://en.wikipedia.org/wiki/GeoJSON) is input and output, so does turf-ruby.
from = { type: "Feature", geometry: { type: "Point", coordinates: [-75.343, 39.984] } }
to = { type: "Feature", geometry: { type: "Point", coordinates: [-75.534, 39.123] } }

Turf::distance(from, to, units: 'miles')
# 60.35329997171344
```

You can view all methods here: [https://formigarafa.github.io/turf-ruby/](https://formigarafa.github.io/turf-ruby/). Most methods have their documentation linked to Turf.js.

## Progress

Currently not all functions are available, feel free to fork the repo and port missing functions you need by reading [source code of Turf.js](https://github.com/Turfjs/turf/tree/master/packages/). And don't forget to open a pull-request afterward.

This list should be updated from [https://github.com/Turfjs/turf/blob/master/documentation.yml](https://github.com/Turfjs/turf/blob/master/documentation.yml).

### Measurement
- [x] along
- [x] area
- [ ] bbox
- [ ] bbox_polygon
- [x] bearing
- [ ] center
- [ ] center_of_mass
- [x] centroid
- [x] destination
- [x] distance
- [ ] envelope
- [ ] great_circle
- [x] length
- [ ] midpoint
- [ ] point_on_feature
- [ ] point_to_line_distance
- [ ] point_to_polygon_distance
- [ ] polygon_tangents
- [ ] rhumb_bearing
- [ ] rhumb_destination
- [ ] rhumb_distance
- [ ] square

### Coordinate Mutation
- [ ] clean_coords
- [ ] flip
- [ ] rewind
- [x] round
- [x] truncate

### Transformation
- [ ] bbox_clip
- [ ] bezier_spline
- [ ] buffer
- [x] circle
- [ ] clone
- [ ] concave
- [ ] convex
- [ ] difference
- [ ] dissolve
- [ ] intersect
- [ ] line_offset
- [ ] polygon_smooth
- [ ] simplify
- [ ] tesselate
- [ ] transform_rotate
- [ ] transform_scale
- [ ] transform_translate
- [ ] union
- [ ] voronoi

### Feature Conversion
- [ ] combine
- [x] explode
- [ ] flatten
- [ ] line_to_polygon
- [ ] polygon_to_line
- [ ] polygonize

### Misc
- [ ] kinks
- [ ] line_arc
- [ ] line_chunk
- [ ] line_intersect
- [ ] line_overlap
- [ ] line_segment
- [ ] line_slice
- [ ] line_slice_along
- [ ] line_split
- [ ] mask
- [ ] nearest_point_on_line
- [ ] sector
- [ ] shortest_path
- [ ] unkink_polygon

### Helper
- [x] feature
- [x] feature_collection
- [x] geometry_collection
- [x] line_string
- [x] multi_line_string
- [x] multi_point
- [x] multi_polygon
- [x] point
- [x] polygon

### Random
- [ ] random_line_string
- [ ] random_point
- [ ] random_polygon
- [ ] random_position

### Data
- [ ] sample

### Interpolation
- [ ] interpolate
- [ ] isobands
- [ ] isolines
- [ ] planepoint
- [ ] tin

### Joins
- [ ] points_within_polygon
- [ ] tag

### Grids
- [ ] hex_grid
- [ ] point_grid
- [ ] square_grid
- [ ] triangle_grid

### Classification
- [ ] nearest_point

### Aggregation
- [ ] clusters_dbscan
- [ ] clusters_kmeans
- [ ] collect

### Meta
- [ ] cluster_each
- [ ] cluster_reduce
- [x] coord_all
- [x] coord_each
- [x] coord_reduce
- [x] feature_each
- [x] feature_reduce
- [x] flatten_each
- [x] flatten_reduce
- [x] geom_each
- [x] geom_reduce
- [ ] get_cluster
- [x] get_coord
- [x] get_coords
- [x] get_geom
- [x] get_type
- [x] prop_each
- [x] prop_reduce
- [x] segment_each
- [x] segment_reduce

### Assertions
- [x] collection_of
- [x] contains_number
- [x] feature_of
- [x] geojson_type

### Booleans
- [ ] boolean_clockwise
- [ ] boolean_concave
- [ ] boolean_contains
- [ ] boolean_crosses
- [ ] boolean_disjoint
- [ ] boolean_equal
- [ ] boolean_intersects
- [ ] boolean_overlap
- [ ] boolean_parallel
- [x] boolean_point_in_polygon
- [ ] boolean_point_on_line
- [ ] boolean_touches
- [ ] boolean_within

### Unit Conversion
- [x] azimuth_to_bearing
- [x] bearing_to_azimuth
- [x] convert_area
- [x] convert_length
- [x] degrees_to_radians
- [x] length_to_degrees
- [x] length_to_radians
- [x] radians_to_degrees
- [x] radians_to_length
- [ ] to_mercator
- [ ] to_wgs84

### Other
- [ ] angle
- [ ] boolean_valid
- [ ] center_mean
- [ ] center_median
- [ ] directional_mean
- [ ] distance_weight
- [ ] ellipse
- [x] find_point
- [x] find_segment
- [x] geometry
- [x] is_number
- [x] is_object
- [x] line_each
- [x] line_reduce
- [x] line_strings
- [ ] moran_index
- [ ] nearest_neighbor_analysis
- [ ] nearest_point_to_line
- [ ] p_norm_distance
- [x] points
- [x] polygons
- [ ] quadrat_analysis
- [x] rbush
- [ ] rectangle_grid
- [ ] standard_deviational_ellipse

### Constants
- [ ] K_TABLE
- [x] AREA_FACTORS
- [x] EARTH_RADIUS
- [x] FACTORS


## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/formigarafa/turf-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of Conduct

Everyone interacting in the Turf Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Great Thanks

Great thanks to people that care to share and helping with the evolution of the community:

- [@layerssss](https://github.com/layerssss) - Michael Yin
- [@Henridv](https://github.com/Henridv) - Henri De Veene
