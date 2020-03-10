# frozen_string_literal: true

require "turf/version"

module Turf
  class Error < StandardError; end

  # A non-intrusive implemenation of Rails' Hash#deep_symbolize_keys
  def self.deep_symbolize_keys(hash)
    return hash unless hash.is_a? Hash

    hash.transform_keys(&:to_sym).transform_values do |value|
      deep_symbolize_keys(value)
    end
  end
end
