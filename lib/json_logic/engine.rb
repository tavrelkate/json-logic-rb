# frozen_string_literal: true

require_relative 'semantics'

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

    def evaluate(rule, data = nil)
      case rule
      when Numeric, String, TrueClass, FalseClass, NilClass
        rule
      when Array
        rule.map { |r| evaluate(r, data) }
      when Hash
        unless rule.one?
          return rule.transform_values { |value| evaluate(value, data) }
        end

        name, raw_args = rule.first
        op_class = @registry.fetch(name)
        unless op_class
          return rule.transform_values { |value| evaluate(value, data) }
        end

        args = op_class.values_only? ? Array.wrap([evaluate(raw_args, data)]) : raw_args
        begin
          result = op_class.new.call(args, data)
          raise JsonLogic::NaNError.new if result.is_a?(Float) && (result.nan? || result.infinite?)
          result
        rescue JsonLogic::LogicError
          raise
        rescue ArgumentError, IndexError, TypeError, NoMethodError
          raise JsonLogic::InvalidArgumentsError.new
        rescue ZeroDivisionError, FloatDomainError
          raise JsonLogic::NaNError.new
        rescue StandardError => e
          raise JsonLogic::LogicError.new("type" => e.message.to_s)
        end
      else
        rule
      end
    end
  end
end
