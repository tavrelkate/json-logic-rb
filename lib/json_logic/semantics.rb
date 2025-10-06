# frozen_string_literal: true

module JsonLogic
  module Semantics
    module_function

    def truthy?(v)
      case v
      when nil then false
      when TrueClass, FalseClass then v
      when Numeric then !v.zero?
      when String then !v.empty?
      when Array  then !v.empty?
      else true
      end
    end

    def falsy?(v) = !truthy?(v)

    def to_number(v)
      return v.to_f if v.is_a?(Numeric) || v.is_a?(String)
      v.to_s.to_f
    end

    def strict_equal(a,b)
      if a.is_a?(Numeric) && b.is_a?(Numeric)
        a.to_f == b.to_f
      else
        a.class == b.class && a == b
      end
    end

    def loose_equal(a,b)
      if (a.is_a?(Numeric)||a.is_a?(String)) && (b.is_a?(Numeric)||b.is_a?(String))
        to_number(a) == to_number(b)
      else
        a == b
      end
    end
  end
end
