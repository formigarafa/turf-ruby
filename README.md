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

Measurement

- [x] along
- [x] area
- [ ] bbox
- [ ] bboxPolygon
- [x] bearing
- [ ] center
- [ ] centerOfMass
- [x] centroid
- [x] destination
- [x] distance
- [ ] envelope
- [x] length
- [ ] midpoint
- [ ] pointOnFeature
- [ ] polygonTangents
- [ ] pointToLineDistance
- [ ] rhumbBearing
- [ ] rhumbDestination
- [ ] rhumbDistance
- [ ] square
- [ ] greatCircle

Coordinate Mutation

- [ ] cleanCoords
- [ ] flip
- [ ] rewind
- [ ] round
- [ ] truncate

Transformation

- [ ] bboxClip
- [ ] bezierSpline
- [ ] buffer
- [ ] circle
- [ ] clone
- [ ] concave
- [ ] convex
- [ ] difference
- [ ] dissolve
- [ ] intersect
- [ ] lineOffset
- [ ] polygonSmooth
- [ ] simplify
- [ ] tesselate
- [ ] transformRotate
- [ ] transformTranslate
- [ ] transformScale
- [ ] union
- [ ] voronoi

Feature Conversion

- [ ] combine
- [ ] explode
- [ ] flatten
- [ ] lineToPolygon
- [ ] polygonize
- [ ] polygonToLine

Misc

- [ ] kinks
- [ ] lineArc
- [ ] lineChunk
- [ ] lineIntersect
- [ ] lineOverlap
- [ ] lineSegment
- [ ] lineSlice
- [ ] lineSliceAlong
- [ ] lineSplit
- [ ] mask
- [ ] nearestPointOnLine
- [ ] sector
- [ ] shortestPath
- [ ] unkinkPolygon

Helper

- [x] featureCollection
- [x] feature
- [x] geometryCollection
- [x] lineString
- [x] multiLineString
- [x] multiPoint
- [x] multiPolygon
- [x] point
- [x] polygon

Random

- [ ] randomPosition
- [ ] randomPoint
- [ ] randomLineString
- [ ] randomPolygon

Data

- [ ] sample

Interpolation

- [ ] interpolate
- [ ] isobands
- [ ] isolines
- [ ] planepoint
- [ ] tin

Joins

- [ ] pointsWithinPolygon
- [ ] tag

Grids

- [ ] hexGrid
- [ ] pointGrid
- [ ] squareGrid
- [ ] triangleGrid

Classification

- [ ] nearestPoint

Aggregation

- [ ] collect
- [ ] clustersDbscan
- [ ] clustersKmeans

Meta

- [ ] coordAll
- [x] coordEach
- [x] coordReduce
- [x] featureEach
- [x] featureReduce
- [x] flattenEach
- [x] flattenReduce
- [x] getCoord
- [ ] getCoords
- [x] getGeom
- [ ] getType
- [x] geomEach
- [x] geomReduce
- [ ] propEach
- [ ] propReduce
- [ ] segmentEach
- [ ] segmentReduce
- [ ] getCluster
- [ ] clusterEach
- [ ] clusterReduce

Assertions

- [ ] collectionOf
- [ ] containsNumber
- [ ] geojsonType
- [ ] featureOf

Booleans

- [ ] booleanClockwise
- [ ] booleanConcave
- [ ] booleanContains
- [ ] booleanCrosses
- [ ] booleanDisjoint
- [ ] booleanEqual
- [ ] booleanIntersects
- [ ] booleanOverlap
- [ ] booleanParallel
- [x] booleanPointInPolygon
- [ ] booleanPointOnLine
- [ ] booleanWithin

Unit Conversion

- [ ] bearingToAzimuth
- [ ] convertArea
- [ ] convertLength
- [ ] degreesToRadians
- [x] lengthToRadians
- [x] lengthToDegrees
- [x] radiansToLength
- [x] radiansToDegrees
- [ ] toMercator
- [ ] toWgs84

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
