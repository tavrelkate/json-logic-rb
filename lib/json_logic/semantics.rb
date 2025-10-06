# frozen_string_literal: true

module JsonLogic
  module Semantics
    NUMERIC_RE = /\A[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\z/.freeze

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
      case v
      when Integer then v
      when Numeric then v.to_f
      when String
        s = v.strip
        return nil unless NUMERIC_RE.match?(s)
        s =~ /[.eE]/ ? s.to_f : s.to_i
      else
        nil
      end
    end

    def strict_equal(a,b)
      if a.is_a?(Numeric) && b.is_a?(Numeric)
        a.to_f == b.to_f
      else
        a.class == b.class && a == b
      end
    end

    def loose_equal(a, b)
      if (a.is_a?(Numeric) || a.is_a?(String)) && (b.is_a?(Numeric) || b.is_a?(String))
        na = to_number(a)
        nb = to_number(b)
        return na == nb unless na.nil? || nb.nil?
      end
      a == b
    end
  end
end
