# frozen_string_literal: true

require_relative 'semantics'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/deep_dup'

module JsonLogic
  class Engine
    include Semantics

    def self.default
      @default ||= new(registry: Registry.new)
    end

    def initialize(registry:)
      @registry = registry
    end

    attr_reader :registry

    def evaluate(expression, data = nil)
      apply(expression, freshen(data))
    end

    private

    def freshen(data)
      case data
      when Hash
        data.deep_dup.with_indifferent_access
      when Array
        data.map { |item| freshen(item) }
      when nil
        {}.with_indifferent_access
      else
        data.duplicable? ? data.dup : data
      end
    end

    def apply(expression, data)
      case expression
      when Numeric, String, TrueClass, FalseClass, NilClass
        expression
      when Array
        expression.map { |item| apply(item, data) }
      when Hash
        return expression if expression.empty?

        name, input = expression.first
        operation = @registry.fetch(name)
        
        raise ArgumentError, "unknown operation: #{name}" unless operation

        args = Array(input)

        if operation.values_only?
          values = args.map { |arg| apply(arg, data) }
          operation.new.call(values, data)
        else
          operation.new.call(args, data)
        end
      else
        expression
      end
    end
  end
end
