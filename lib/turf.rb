# frozen_string_literal: true

require "turf/version"

module Turf
  class Error < StandardError; end

  # this list should correspond to:
  #
  #   https://github.com/Turfjs/turf/blob/master/documentation.yml
  #
  include Turf::Measurement
  # include Turf::CoordinateMutation
  # include Turf::Transformation
  # include Turf::FeatureConversion
  # include Turf::Misc
  include Turf::Helper
  # include Turf::Data
  # include Turf::Interpolation
  # include Turf::Joins
  # include Turf::Grids
  # include Turf::Classification
  # include Turf::Aggregation
  include Turf::Meta
  # include Turf::Assertions
  include Turf::Booleans
  include Turf::UnitConversion

  extend self

  private

  # A non-intrusive implemenation of Rails' Hash#deep_symbolize_keys
  def deep_symbolize_keys(hash)
    return hash unless hash.is_a? Hash

    hash.transform_keys(&:to_sym).transform_values do |value|
      deep_symbolize_keys(value)
    end
  end
end
