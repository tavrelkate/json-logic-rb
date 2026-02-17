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

    def to_primitive(v)
      case v
      when Array then v.join(',')
      else v
      end
    end

    def num(v)
      case v
      when Numeric    then v.to_f
      when TrueClass  then 1.0
      when FalseClass then 0.0
      when NilClass   then 0.0
      when Array      then Float::NAN
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
      return a.eql?(b) if a.is_a?(String) && b.is_a?(String)
      raise FloatDomainError, "NaN" if a.is_a?(Array) || b.is_a?(Array) || a.is_a?(Hash) || b.is_a?(Hash)

      ax = num(a)
      bx = num(b)
      raise FloatDomainError, "NaN" if ax.nan? || bx.nan?

      ax == bx
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

    def cmp!(a, b)
      c = cmp(a, b)
      raise FloatDomainError, "NaN" if c.nil?

      c
    end

    refine Object do
      def !@
        JsonLogic::Semantics.truthy?(self) ? false : true
      end

      def to_bool
        JsonLogic::Semantics.truthy?(self)
      end
    end

    [String, Integer, Float, NilClass, Array, TrueClass, FalseClass].each do |klass|
      refine klass do
        def to_f
          case self
          when Integer, Float
            self * 1.0
          when TrueClass
            1.0
          when FalseClass, NilClass
            0.0
          when String
            s = strip
            return 0.0 if s.empty?
            Float(s)
          when Array
            raise FloatDomainError, "NaN"
          else
            raise FloatDomainError, "NaN"
          end
        rescue ArgumentError
          raise FloatDomainError, "NaN"
        end

        def ==(other) = JsonLogic::Semantics.eq(self, other)
        def >(other)
          case JsonLogic::Semantics.cmp!(self, other)
          when 1 then true
          else false
          end
        end

        def >=(other)
          case JsonLogic::Semantics.cmp!(self, other)
          when 1, 0 then true
          else false
          end
        end

        def <(other)
          case JsonLogic::Semantics.cmp!(self, other)
          when -1 then true
          else false
          end
        end

        def <=(other)
          case JsonLogic::Semantics.cmp!(self, other)
          when -1, 0 then true
          else false
          end
        end
      end
    end

    refine Hash do
      def to_f
        raise FloatDomainError, "NaN"
      end

      def ==(other)
        return eql?(other) if other.is_a?(Hash)
        JsonLogic::Semantics.eq(self, other)
      end

      def >(other)
        case JsonLogic::Semantics.cmp!(self, other)
        when 1 then true
        else false
        end
      end

      def >=(other)
        case JsonLogic::Semantics.cmp!(self, other)
        when 1, 0 then true
        else false
        end
      end

      def <(other)
        case JsonLogic::Semantics.cmp!(self, other)
        when -1 then true
        else false
        end
      end

      def <=(other)
        case JsonLogic::Semantics.cmp!(self, other)
        when -1, 0 then true
        else false
        end
      end
    end

    refine Object do
      def to_f
        raise FloatDomainError, "NaN"
      end
    end
  end
end
