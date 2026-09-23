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
      return a.eql?(b) if a.is_a?(Hash) && b.is_a?(Hash)
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

    # `to_f`/`to_bool`/`as_array` are NOT backed by an MRI opt_* VM
    # instruction, so refining them directly on core classes is safe:
    # confirmed by benchmark to add zero overhead outside the `using`
    # scope that activates them.
    refine Object do
      def to_bool = JsonLogic::Semantics.truthy?(self)

      def as_array = [self]

      def to_f
        raise FloatDomainError, "NaN"
      end
    end

    refine Array do
      def as_array = self
    end

    [String, Integer, Float, NilClass, TrueClass, FalseClass].each do |klass|
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
          end
        rescue ArgumentError
          raise FloatDomainError, "NaN"
        end
      end
    end

    # `==`, `<`, `>`, `<=`, `>=` and `!@` ARE backed by opt_* VM
    # instructions (opt_eq/opt_lt/opt_gt/opt_le/opt_ge/opt_not). Refining
    # them directly on core classes -- via `refine`, `prepend`, or a plain
    # monkeypatch -- permanently disables those fast paths for the whole
    # process, confirmed by benchmark, even when the refinement is never
    # activated via `using` anywhere (this is the #27 regression). There
    # is no way to intercept these specific operators on real
    # Integer/Array/String/Hash instances without that cost.
    #
    # So operation bodies never see a wrapper: `Value` and the wrapping
    # itself stay behind the scenes.
    #   - Operations that fetch their comparison values by calling
    #     `JsonLogic.apply` themselves (equal, gt, if, and, ...) get them
    #     pre-wrapped: `AutoWrap` refines *our own* `JsonLogic` module's
    #     singleton class (not a core class -- no opt_* involved, so this
    #     carries no cost of its own) so `JsonLogic.apply` returns a
    #     `Value` wherever `using ...::AutoWrap` is active.
    #   - Operations that instead receive an already-evaluated argument
    #     (not, bool_cast) get it wrapped by `WrapArgs`, prepended onto
    #     those two classes from json_logic.rb once they're loaded --
    #     `Operation` is our own class too, so `prepend` here is likewise
    #     free of the core-class cost.
    # `Value` itself is a plain class (not a core class), so its own
    # operators are just ordinary methods -- no `refine` needed for them.
    class Value
      attr_reader :raw

      def initialize(raw) = @raw = raw

      def self.unwrap(v) = v.is_a?(Value) ? v.raw : v

      def ==(other) = Semantics.eq(raw, Value.unwrap(other))

      def >(other)
        case Semantics.cmp!(raw, Value.unwrap(other))
        when 1 then true
        else false
        end
      end

      def >=(other)
        case Semantics.cmp!(raw, Value.unwrap(other))
        when 1, 0 then true
        else false
        end
      end

      def <(other)
        case Semantics.cmp!(raw, Value.unwrap(other))
        when -1 then true
        else false
        end
      end

      def <=(other)
        case Semantics.cmp!(raw, Value.unwrap(other))
        when -1, 0 then true
        else false
        end
      end

      def !@
        Semantics.truthy?(raw) ? false : true
      end
    end

    module AutoWrap
      refine JsonLogic.singleton_class do
        def apply(rule, data = nil) = Value.new(super)
      end
    end

    module WrapArgs
      def call(args, data)
        wrapped = args.is_a?(Array) ? args.map { |a| Value.new(a) } : Value.new(args)
        super(wrapped, data)
      end
    end
  end
end
