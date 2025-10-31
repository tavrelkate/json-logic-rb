# frozen_string_literal: true

module JsonLogic
  module Semantics
    module_function

    def truthy?(v)
      case v
      when nil
        false
      when TrueClass, FalseClass
        v
      when Numeric
        v.zero? ? false : true
      when String
        v.empty? ? false : true
      when Array
        v.empty? ? false : true
      else
        true
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
        begin
          Float(s)
        rescue ArgumentError
          Float::NAN
        end
      else
        Float::NAN
      end
    end

    def eq(a, b)
      if a.class == b.class
        if a.is_a?(Numeric)
          return false if a.to_f.nan? || b.to_f.nan?
          return a.to_f == b.to_f
        else
          return a.eql?(b)
        end
      end

      if a.is_a?(TrueClass) || a.is_a?(FalseClass) || b.is_a?(TrueClass) || b.is_a?(FalseClass)
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

    refine Object do
      def !@
        JsonLogic::Semantics.truthy?(self) ? false : true
      end

      def to_bool
        JsonLogic::Semantics.truthy?(self)
      end
    end

    refine String do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
      def >(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == 1
      def >=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == 1 || c == 0)
      def <(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == -1
      def <=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == -1 || c == 0)
    end

    refine Integer do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
      def >(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == 1
      def >=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == 1 || c == 0)
      def <(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == -1
      def <=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == -1 || c == 0)
    end

    refine Float do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
      def >(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == 1
      def >=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == 1 || c == 0)
      def <(other)  = (c = JsonLogic::Semantics.cmp(self, other)) && c == -1
      def <=(other) = (c = JsonLogic::Semantics.cmp(self, other)) && (c == -1 || c == 0)
    end

    refine Array do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
    end

    refine TrueClass do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
    end

    refine FalseClass do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
    end

    refine NilClass do
      def ==(other) = JsonLogic::Semantics.eq(self, other)
    end
  end
end
