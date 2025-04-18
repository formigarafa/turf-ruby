# frozen_string_literal: true

require "turf/version"

# Ruby port of Turf.js, an advance geospatial analysis library.
# @see https://turfjs.org/
module Turf
  # Error thrown by turf-ruby
  class Error < StandardError; end

  class NotImplementedError < Error; end

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

  def deep_symbolize_keys!(input)
    case input
    when Hash
      input.transform_keys!(&:to_sym).transform_values do |value|
        deep_symbolize_keys!(value)
      end
    when Array
      input.map do |value|
        deep_symbolize_keys! value
      end
    end
    input
  end

  def deep_dup(input)
    if input.is_a?(Hash)
      duppe = {}
      input.each_pair do |key, value|
        if key.is_a?(::String) || key.is_a?(::Symbol)
          duppe[key] = deep_dup(value)
        else
          duppe.delete(key)
          duppe[deep_dup(key)] = deep_dup(value)
        end
      end
      duppe
    elsif input.is_a?(Array)
      input.map { |i| deep_dup(i) }
    else
      input.dup
    end
  end
end
