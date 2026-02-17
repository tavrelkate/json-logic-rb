# frozen_string_literal: true

class Array
  def self.wrap(value)
    return [] if value.nil?
    return Array(value) unless value.is_a?(Array)
    return value unless value.one?

    first = value.first
    return value if first.nil? || first.is_a?(Hash)

    Array(first)
  end
end
