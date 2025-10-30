# frozen_string_literal: true

module JsonLogic
  module Semantics
    module_function

    def truthy?(v)
      case v
      when nil then false
      when TrueClass, FalseClass then v
      when Numeric then !v.zero?
      when String, Array then !v.empty?
      else true
      end
    end

    def num(v)
      case v
      when Numeric    then v.to_f
      when TrueClass  then 1.0
      when FalseClass then 0.0
      when NilClass   then 0.0
      when Array      then num(v.join(','))
      when String
        s = v.strip
        return 0.0 if s.empty?
        Float(s) rescue Float::NAN
      else
        Float::NAN
      end
    end

    def eq(a, b)
      if a.class == b.class
        return false if a.is_a?(Numeric) && (a.to_f.nan? || b.to_f.nan?)
        return a.is_a?(Numeric) ? (a.to_f == b.to_f) : a.eql?(b)
      end

      if a == true || a == false || b == true || b == false
        na = num(a); nb = num(b)
        return false if na.nan? || nb.nan?
        return na == nb
      end

      if (a.is_a?(String) && b.is_a?(Numeric)) || (a.is_a?(Numeric) && b.is_a?(String))
        na = num(a); nb = num(b)
        return false if na.nan? || nb.nan?
        return na == nb
      end

      false
    end

    def cmp(a, b)
      if a.is_a?(String) && b.is_a?(String)
        a <=> b
      else
        x = num(a); y = num(b)
        return nil if x.nan? || y.nan?
        x <=> y
      end
    end

    [String, Integer, TrueClass, FalseClass, NilClass, Array].each do |klass|
      refine klass do
        def ==(other) = JsonLogic::Semantics.eq(self, other)

        def >(other)
          c = JsonLogic::Semantics.cmp(self, other)
          c && c == 1
        end

        def >=(other)
          c = JsonLogic::Semantics.cmp(self, other)
          c && (c == 1 || c == 0)
        end

        def <(other)
          c = JsonLogic::Semantics.cmp(self, other)
          c && c == -1
        end

        def <=(other)
          c = JsonLogic::Semantics.cmp(self, other)
          c && (c == -1 || c == 0)
        end
      end
    end
  end
end
