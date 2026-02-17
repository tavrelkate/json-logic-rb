# frozen_string_literal: true

class Array
  def self.wrap(value) = value.is_a?(Array) ? value : [value]
end
