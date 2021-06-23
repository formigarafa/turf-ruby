# frozen_string_literal: true

require "turf/version"

# Ruby port of Turf.js, an advance geospatial analysis library.
# @see https://turfjs.org/
module Turf
  # Error thrown by turf-ruby
  class Error < StandardError; end

  extend self

  private

  # A non-intrusive implemenation of Rails' Hash#deep_symbolize_keys
  def deep_symbolize_keys(input)
    case input
    when Hash
      input.transform_keys(&:to_sym).transform_values do |value|
        deep_symbolize_keys(value)
      end
    when Array
      input.map do |value|
        deep_symbolize_keys value
      end
    else
      input
    end
  end
end
